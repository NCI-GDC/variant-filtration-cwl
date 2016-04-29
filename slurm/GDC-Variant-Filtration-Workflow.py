'''
Main wrapper script for staging a VEP run.
'''
import os
import time
import argparse
import logging
import sys
import uuid
import tempfile
import utils.s3
import utils.pipeline
import datetime

import postgres.status
import postgres.utils
import postgres.time
from sqlalchemy.exc import NoSuchTableError

def run_build_slurm_scripts(args):
    '''
    Builds the slurm scripts to run variant filtration 
    '''
    # Time
    start = time.time()

    # Check paths
    if not os.path.isdir(args.outdir):
        raise Exception("Cannot find output directory: %s" %args.outdir)

    if not os.path.isfile(args.config):
        raise Exception("Cannot find config file: %s" %args.config)

    # Setup logger
    logger = utils.pipeline.setup_logging(logging.INFO, 'VariantFiltrationSLURM', args.log_file)

    # Load template
    template_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'etc/template.sh')
    template_str  = None
    with open(template_file, 'r') as fh:
        template_str = fh.read()

    # Database setup
    engine = postgres.utils.get_db_engine(args.config) 

    try:
        cases = postgres.status.get_fpfilter_inputs_from_status(engine, 'fpfilter_cwl_status')
        write_slurm_script(cases, args, template_str)
    except NoSuchTableError:
        cases = postgres.status.get_all_fpfilter_inputs(engine)
        write_slurm_script(cases, args, template_str)

def write_slurm_script(cases, args, template_str):
    '''
    Writes the actual slurm script file based on the template
    '''
    for case in cases:
        dat = cases[case]
        if all([dat.src_vcf_id, dat.src_vcf_location, dat.case_id, dat.normal_gdc_id, 
                dat.tumor_gdc_id, dat.pipeline, dat.tumor_bam_location]): 
            slurm = os.path.join(args.outdir, 'fpfilter_cwl.{0}.sh'.format(dat.src_vcf_id))
            cwl   = 'variant-filtration.fpfilter.cwl.yaml' if dat.pipeline == 'varscan' \
                    else 'variant-filtration.fpfilter.somaticscore.cwl.yaml'

            val   = template_str.format(
                THREAD_COUNT        = args.thread_count,
                MEM                 = args.mem,
                SRC_VCF_ID          = dat.src_vcf_id,
                INPUT_VCF           = dat.src_vcf_location,
                INPUT_BAM           = dat.tumor_bam_location,
                WORKFLOW_CWL        = cwl,
                CASE_ID             = dat.case_id,
                TUMOR_BAM_UUID      = dat.tumor_gdc_id,
                NORMAL_BAM_UUID     = dat.normal_gdc_id, 
                REFDIR              = args.refdir,
                S3DIR               = args.s3dir,
                BASEDIR             = args.run_basedir
            ) 

            with open(slurm, 'w') as o:
                o.write(val)


def run_cwl(args):
    '''
    Executes the CWL pipeline and adds status tables
    '''
    if not os.path.isdir(args.basedir):
        raise Exception("Could not find path to base directory: %s" %args.basedir)

    #generate a random uuid
    vcf_uuid = uuid.uuid4()

    #create directory structure
    uniqdir = tempfile.mkdtemp(prefix="fpfilter_%s_" % str(vcf_uuid), dir=args.basedir)
    workdir = tempfile.mkdtemp(prefix="workdir_", dir=uniqdir)
    inp     = tempfile.mkdtemp(prefix="input_", dir=uniqdir)
    index   = args.refdir

    #setup logger
    log_file = os.path.join(workdir, "%s.fpfilter.cwl.log" %str(vcf_uuid))
    logger = utils.pipeline.setup_logging(logging.INFO, str(vcf_uuid), log_file)

    #logging inputs
    logger.info("normal_bam_uuid: %s" %(args.normal_bam_uuid))
    logger.info("tumor_bam_uuid: %s" %(args.tumor_bam_uuid))
    logger.info("case_id: %s" %(args.case_id))
    logger.info("src_vcf_id: %s" %(args.src_vcf_id))
    logger.info("vcf_id: %s" %(str(vcf_uuid)))

    #Get datetime
    datetime_now = str(datetime.datetime.now())
    #Get CWL start time
    cwl_start = time.time()

    # getting refs
    logger.info("getting refs")
    ref_fasta    = os.path.join(index, "GRCh38.d1.vd1.fa") 
    pg_config    = os.path.join(index, "postgres_config")

    # Download input vcf
    logger.info("getting input VCF")
    input_vcf = os.path.join(inp, os.path.basename(args.input_vcf))
    get_input_vcf(logger, input_vcf, inp, cwl_start, uniqdir, args, vcf_uuid, datetime_now, pg_config)
    
    # Download input bam 
    logger.info("getting input BAM")
    input_bam = os.path.join(inp, os.path.basename(args.input_bam))
    get_input_bam(logger, input_bam, inp, cwl_start, uniqdir, args, vcf_uuid, datetime_now, pg_config)

    # Unzip input VCF if gzip
    if input_vcf.endswith('.gz'):
        logger.info("unzipping input VCF")
        exit_code = utils.pipeline.gzip_decompress(logger, input_vcf)
        input_vcf = input_vcf.replace('.gz','')

    # Start CWL
    os.chdir(workdir)

    #run cwl command
    logger.info("running CWL workflow")
    cmd = ['/home/ubuntu/.virtualenvs/p2/bin/cwltool',
            "--debug",
            "--tmpdir-prefix", inp,
            "--tmp-outdir-prefix", workdir,
            args.cwl,
            "--postgres_config", pg_config,
            "--host", args.host,
            "--input_vcf", input_vcf,
            "--input_bam", input_bam,
            "--vcf_id", str(vcf_uuid),
            "--src_vcf_id", args.src_vcf_id,
            "--case_id", args.case_id,
            "--tumor_bam_uuid", args.tumor_bam_uuid,
            "--normal_bam_uuid", args.normal_bam_uuid,
            "--reference", ref_fasta,
            "--threads", str(args.threads)]
    cwl_exit = utils.pipeline.run_command(cmd, logger)

    cwl_failure = False
    if cwl_exit:
        cwl_failure = True

    #upload results to s3

    logger.info("Uploading to s3")
    fpfilter_location   = os.path.join(args.s3dir, str(vcf_uuid))
    vcf_file            = "%s.fpfilter.vcf.gz" %(str(vcf_uuid))
    vcf_upload_location = os.path.join(fpfilter_location, vcf_file)
    s3put_exit          = utils.s3.aws_s3_put(logger, fpfilter_location, workdir,
                                              "ceph", "http://gdc-cephb-objstore.osdc.io/")

    full_vcf_file_path  = os.path.join(workdir, vcf_file)

    cwl_end = time.time()
    cwl_elapsed = cwl_end - cwl_start

    #establish connection with database
    engine = postgres.utils.get_db_engine(pg_config)

    # Get status info
    status, loc = postgres.status.get_status(s3put_exit, cwl_failure, vcf_upload_location,
                                             fpfilter_location, logger)

    # Set metrics table
    met = postgres.time.Time(case_id = args.case_id,
               datetime_now = datetime_now,
               vcf_id = str(vcf_uuid),
               src_vcf_id = args.src_vcf_id,
               files = [args.normal_bam_uuid, args.tumor_bam_uuid],
               elapsed = cwl_elapsed,
               thread_count = str(args.threads),
               status = str(status))

    postgres.utils.create_table(engine, met)
    postgres.utils.add_metrics(engine, met)

    # Get md5
    md5 = 'UNKNOWN'
    if os.path.isfile(full_vcf_file_path):
        md5 = utils.pipeline.get_md5(full_vcf_file_path)

    # Set status table
    logger.info("Updating status")
    postgres.status.add_status(engine, args.case_id, str(vcf_uuid), args.src_vcf_id,
                              [args.normal_bam_uuid, args.tumor_bam_uuid], status,
                              loc, datetime_now, md5)

    #remove work and input directories
    logger.info("Removing files")
    #utils.pipeline.remove_dir(uniqdir)

def get_input_vcf(logger, input_vcf, inp, cwl_start, uniqdir, args, vcf_uuid, datetime_now, pg_config):
    '''Pulls down vcf''' 
    if args.input_vcf.startswith('s3://washu_varscan_variant') or args.input_vcf.startswith('s3://washu_sniper_variant') \
      or args.input_vcf.startswith('s3://ceph'): 
        exit_code = utils.s3.aws_s3_get(logger, args.input_vcf, inp,
                                        "ceph", "http://gdc-cephb-objstore.osdc.io/", recursive=False)
    else:
        exit_code = utils.s3.aws_s3_get(logger, args.input_vcf, inp,
                                        "cleversafe", "http://gdc-accessors.osdc.io/", recursive=False)

    # If we can't download vcf error
    if exit_code != 0:
        cwl_end     = time.time()
        cwl_elapsed = cwl_end - cwl_start
        engine      = postgres.utils.get_db_engine(pg_config)
        postgres.status.set_download_error(exit_code, args.case_id, str(vcf_uuid),
            args.src_vcf_id, [args.normal_bam_uuid, args.tumor_bam_uuid],
            datetime_now, str(args.threads), cwl_elapsed, engine, logger, 'VCF')

        #remove work and input directories
        logger.info("Removing files")
        utils.pipeline.remove_dir(uniqdir)

        # Exit
        sys.exit(exit_code)

    # If downloaded file is size 0
    elif utils.pipeline.get_file_size(input_vcf) == 0:
        cwl_end     = time.time()
        cwl_elapsed = cwl_end - cwl_start
        engine = postgres.utils.get_db_engine(pg_config)
        postgres.status.set_download_error(s3_exit_code, args.case_id, str(vcf_uuid),
            args.src_vcf_id, [args.normal_bam_uuid, args.tumor_bam_uuid],
            datetime_now, str(args.threads), cwl_elapsed, engine, logger, 'VCF')

        #remove work and input directories
        logger.info("Removing files")
        utils.pipeline.remove_dir(uniqdir)

        # Exit
        sys.exit(1)

## BAMS
#s3://ceph_qcpass_target_exome_coclean
#s3://ceph_qcpass_tcga_exome_blca_coclean
#s3://qcpass_tcga_exome_blca_coclean
def get_input_bam(logger, input_bam, inp, cwl_start, uniqdir, args, vcf_uuid, datetime_now, pg_config):
    '''Pulls down bam''' 
    if args.input_bam.startswith('s3://ceph'): 
        exit_code = utils.s3.aws_s3_get(logger, args.input_bam, inp,
                                        "ceph", "http://gdc-cephb-objstore.osdc.io/", recursive=False)
    else:
        exit_code = utils.s3.aws_s3_get(logger, args.input_bam, inp,
                                        "cleversafe", "http://gdc-accessors.osdc.io/", recursive=False)

    # If we can't download vcf error
    if exit_code != 0:
        cwl_end     = time.time()
        cwl_elapsed = cwl_end - cwl_start
        engine      = postgres.utils.get_db_engine(pg_config)
        postgres.status.set_download_error(exit_code, args.case_id, str(vcf_uuid),
            args.src_vcf_id, [args.normal_bam_uuid, args.tumor_bam_uuid],
            datetime_now, str(args.threads), cwl_elapsed, engine, logger, 'BAM')

        #remove work and input directories
        logger.info("Removing files")
        utils.pipeline.remove_dir(uniqdir)

        # Exit
        sys.exit(exit_code)

    # If downloaded file is size 0
    elif utils.pipeline.get_file_size(input_bam) == 0:
        cwl_end     = time.time()
        cwl_elapsed = cwl_end - cwl_start
        engine = postgres.utils.get_db_engine(pg_config)
        postgres.status.set_download_error(s3_exit_code, args.case_id, str(vcf_uuid),
            args.src_vcf_id, [args.normal_bam_uuid, args.tumor_bam_uuid],
            datetime_now, str(args.threads), cwl_elapsed, engine, logger, 'BAM')

        #remove work and input directories
        logger.info("Removing files")
        utils.pipeline.remove_dir(uniqdir)

        # Exit
        sys.exit(1)

def get_args():
    '''
    Loads the parser
    '''
    # Main parser
    p  = argparse.ArgumentParser(prog='GDC-Variant-Filtration-Workflow')

    # Sub parser 
    sp = p.add_subparsers(help='Choose the process you want to run', dest='choice')

    # Build slurm scripts
    p_slurm = sp.add_parser('slurm', help='Options for building slurm scripts.')
    p_slurm.add_argument('--refdir', required=True, help='Path to the reference directory')
    p_slurm.add_argument('--config', required=True, help='Path to the postgres config file')
    p_slurm.add_argument('--thread_count', required=True, help='number of threads to use')
    p_slurm.add_argument('--mem', required=True, help='mem for each node')
    p_slurm.add_argument('--outdir', default="./", help='output directory for slurm scripts [./]')
    p_slurm.add_argument('--s3dir', default="s3://ceph_fpfilter", help='s3bin for output files [s3://ceph_fpfilter/]')
    p_slurm.add_argument('--run_basedir', default="/mnt/SCRATCH", help='basedir for cwl runs')
    p_slurm.add_argument('--log_file', type=str, help='If you want to write the logs to a file. By default stdout')

    # Args
    p_run = sp.add_parser('run', help='Wrapper for running the Variant Filtration cwl workflow.')
    p_run.add_argument('--refdir', required=True, help='Path to reference directory')
    p_run.add_argument('--basedir', default='/mnt/SCRATCH', help='Path to the postgres config file')
    p_run.add_argument('--host', default="10.64.0.97", help='postgres host name')
    p_run.add_argument('--input_vcf', required=True, help='s3 url for input vcf file')
    p_run.add_argument('--input_bam', required=True, help='s3 url for input bam file')
    p_run.add_argument('--src_vcf_id', required=True, help='Input VCF ID')
    p_run.add_argument('--case_id', required=True, help='case id')
    p_run.add_argument('--tumor_bam_uuid', required=True, help='The tumor bam unique ID')
    p_run.add_argument('--normal_bam_uuid', required=True, help='The normal bam unique ID')
    p_run.add_argument('--threads', type=int, default=1, help='Number of sambamba index threads to use')
    p_run.add_argument('--s3dir', default="s3://ceph_fpfilter", help='s3bin for uploading output files')
    p_run.add_argument('--cwl', required=True, help='Path to Variant Filtration CWL workflow YAML')

    return p.parse_args()

if __name__ == '__main__':
    # Get args
    args = get_args()

    # Run tool 
    if args.choice == 'slurm': run_build_slurm_scripts(args)
    elif args.choice == 'run': run_cwl(args)
