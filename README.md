GDC Variant Filtration CWL
---

This workflow currently only runs fpfilter and filtering of somaticsniper somatic scores.

## To run workflow

1. Stage input files
    * input VCF
    * input tumor bam
    * indexed reference
    * creds
2. Run appropriate workflow:
    * VarScan2 - `variant-filtration.fpfilter.cwl.yaml`
    * SomaticSniper - `variant-filtration.fpfilter.somaticscore.cwl.yaml`
3. Install cwltool
4. Run workflow

## Docker tools used

https://quay.io/repository/ncigdc/variant-filtration-tool <br>
Contains fpfilter, bam-readcount, samtools, sambamba, and support scripts
