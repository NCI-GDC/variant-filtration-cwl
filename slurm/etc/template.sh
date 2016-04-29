#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task={THREAD_COUNT}
#SBATCH --ntasks=1
#SBATCH --workdir={BASEDIR}
#SBATCH --mem={MEM}

# Runtime
thread_count="{THREAD_COUNT}"

# IDS
src_vcf_id="{SRC_VCF_ID}"
case_id="{CASE_ID}"
tumor_bam_uuid="{TUMOR_BAM_UUID}"
normal_bam_uuid="{NORMAL_BAM_UUID}"

# Input
input_vcf="{INPUT_VCF}"
input_bam="{INPUT_BAM}"
workflow_cwl="{WORKFLOW_CWL}"

# Reference DB
refdir="{REFDIR}"

# Outputs
s3dir="{S3DIR}"
basedir="{BASEDIR}"
repository="git@github.com:NCI-GDC/variant-filtration-cwl.git"
wkdir=`sudo mktemp -d fp.XXXXXXXXXX -p $basedir`
sudo chown ubuntu:ubuntu $wkdir

cd $wkdir

function cleanup (){{
    echo "cleanup tmp data";
    sudo rm -rf $wkdir;
}}

sudo git clone -b feat/slurm $repository
sudo chown ubuntu:ubuntu -R variant-filtration-cwl

trap cleanup EXIT

/home/ubuntu/.virtualenvs/p2/bin/python variant-filtration-cwl/slurm/GDC-Variant-Filtration-Workflow.py run \
--basedir $wkdir \
--refdir $refdir \
--input_vcf $input_vcf \
--input_bam $input_bam \
--src_vcf_id $src_vcf_id \
--case_id $case_id \
--tumor_bam_uuid $tumor_bam_uuid \
--normal_bam_uuid $normal_bam_uuid \
--threads $thread_count \
--s3dir $s3dir \
--cwl $wkdir/variant-filtration-cwl/workflows/$workflow_cwl
