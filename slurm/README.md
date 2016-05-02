# Variant-Filtration-CWL Pipeline - SLURM

## Stage the compute nodes

```
# Note: I am using AV2 (deadpool) here, but of course you can change for the appropriate system
# Make refdir
sudo salt -C 'G@az:AV2' cmd.run 'mkdir -p /mnt/SCRATCH/fpfilter/ref'

# Pull reference files (edit the s3 bin where necessary)
sudo salt -C 'G@az:AV2' cmd.run 's3cmd --config /home/ubuntu/.s3cfg get s3://path/to/GRCh38.d1.vd1.fa /mnt/SCRATCH/fpfilter/ref/'
sudo salt -C 'G@az:AV2' cmd.run 's3cmd --config /home/ubuntu/.s3cfg get s3://path/to/GRCh38.d1.vd1.fa.fai /mnt/SCRATCH/fpfilter/ref/'

# Pull postgres config (edit the s3 bin where necessary)
sudo salt -C 'G@az:AV2' cmd.run 's3cmd --config /home/ubuntu/.s3cfg get s3://path/to/postgres_config /mnt/SCRATCH/fpfilter/ref/'

# Make run dir
sudo salt -C 'G@az:AV2' cmd.run 'mkdir /mnt/SCRATCH/fpfilter/run'

# Change owner
sudo salt -C 'G@az:AV2' cmd.run 'sudo chown ubuntu:ubuntu -R /mnt/SCRATCH/fpfilter
```

## Running build command

Run this command to build your SLURM scripts:

```
$ python GDC-Variant-Filtration-Workflow.py slurm --help
usage: GDC-Variant-Filtration-Workflow slurm [-h] --refdir REFDIR --config
                                             CONFIG --thread_count
                                             THREAD_COUNT --mem MEM
                                             [--outdir OUTDIR] [--s3dir S3DIR]
                                             [--run_basedir RUN_BASEDIR]
                                             [--log_file LOG_FILE]

optional arguments:
  -h, --help            show this help message and exit
  --refdir REFDIR       Path to the reference directory
  --config CONFIG       Path to the postgres config file
  --thread_count THREAD_COUNT
                        number of threads to use
  --mem MEM             mem for each node
  --outdir OUTDIR       output directory for slurm scripts [./]
  --s3dir S3DIR         s3bin for output files [s3://ceph_fpfilter/]
  --run_basedir RUN_BASEDIR
                        basedir for cwl runs
  --log_file LOG_FILE   If you want to write the logs to a file. By default
                        stdout
```

This scripts expects the metadata is located in the PG table: `fpfilter_input` and the same has this structure:

```
       Column        |       Type        | Modifiers 
---------------------+-------------------+-----------
 study               | text              | 
 disease             | text              | 
 case_id             | character varying | 
 participant_id      | text              | 
 pipeline            | text              | 
 src_vcf_id          | character varying | 
 src_vcf_location    | character varying | 
 tumor_gdc_id        | character varying | 
 tumor_bam_location  | text              | 
 normal_gdc_id       | character varying | 
 normal_bam_location | text              |
 ```

## Run command

This is the command that the SLURM jobs will run:

```
$ python GDC-Variant-Filtration-Workflow.py run --help
usage: GDC-Variant-Filtration-Workflow run [-h] --refdir REFDIR
                                           [--basedir BASEDIR] [--host HOST]
                                           --input_vcf INPUT_VCF --input_bam
                                           INPUT_BAM --src_vcf_id SRC_VCF_ID
                                           --case_id CASE_ID --tumor_bam_uuid
                                           TUMOR_BAM_UUID --normal_bam_uuid
                                           NORMAL_BAM_UUID [--threads THREADS]
                                           [--s3dir S3DIR] --cwl CWL

optional arguments:
  -h, --help            show this help message and exit
  --refdir REFDIR       Path to reference directory
  --basedir BASEDIR     Path to the postgres config file
  --host HOST           postgres host name
  --input_vcf INPUT_VCF
                        s3 url for input vcf file
  --input_bam INPUT_BAM
                        s3 url for input bam file
  --src_vcf_id SRC_VCF_ID
                        Input VCF ID
  --case_id CASE_ID     case id
  --tumor_bam_uuid TUMOR_BAM_UUID
                        The tumor bam unique ID
  --normal_bam_uuid NORMAL_BAM_UUID
                        The normal bam unique ID
  --threads THREADS     Number of sambamba index threads to use
  --s3dir S3DIR         s3bin for uploading output files
  --cwl CWL             Path to Variant Filtration CWL workflow YAML
```
