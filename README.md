# GDC Variant Filtration CWL

The repository has only been tested on GDC data and in the particular environment GDC is running in. Some of the reference data required
for the workflow production are hosted in
[GDC reference files](https://gdc.cancer.gov/about-data/data-harmonization-and-generation/gdc-reference-files "GDC reference files"). For
any questions related to GDC data, please contact the GDC Help Desk at support@nci-gdc.datacommons.io.

To support different filtering processes for different variant callers, we provide multiple workflows in this repository.

* `minimal` - minimal filters (e.g., MuTect2 and MuSE)
* `with-fpfilter` - minimal + fpfilter (e.g., VarScan2)
* `with-fpfilter.with-somaticscore` - minimal + fpfilter + somaticscore (e.g., SomaticSniper)
* `pindel` - formatting of Pindel VCFs
* `sanger-pindel` - formatting of Sanger-Pindel VCFs

## External Users

The entrypoint CWL workflows for external users are:

* `workflows/subworkflows/gdc-filters.minimal.cwl`
* `workflows/subworkflows/gdc-filters.pindel.cwl`
* `workflows/subworkflows/gdc-filters.sanger-pindel.cwl`
* `workflows/subworkflows/gdc-filters.with-fpfilter.cwl`
* `workflows/subworkflows/gdc-filters.with-fpfilter.with-somaticscore.cwl`

### Inputs

| Name | Type | Workflow | Description |
| ---- | ---- | -------- | ----------- |
| `input_vcf` | `File` | all | The VCF file you want to filter. |
| `tumor_bam` | `File` | `minimal`, `with-fpfilter`, `with-fpfilter.with-somaticscore` | The tumor BAM file. |
| `tumor_bam_index` | `File` | `minimal`, `with-fpfilter`, `with-fpfilter.with-somaticscore` | The tumor BAM file. |
| `file_prefix` | `string` | all | Prefix for all output file basenames. |
| `full_ref_fasta` | `File` | all | Full reference fasta containing all scaffolds. |
| `full_ref_fasta_index` | `File` | all | Full reference fasta index. | 
| `full_ref_dictionary` | `File` | all | Full reference fasta sequence dictionary. |
| `main_ref_fasta` | `File` | all | Main chromosomes only fasta containing all scaffolds. |
| `main_ref_fasta_index` | `File` | all | Main chromosomes only fasta index. | 
| `main_ref_dictionary` | `File` | all | Main chromosomes only fasta sequence dictionary. |
| `vcf_metadata` | `vcf_metadata_record` | all | Custom SchemaDef containing VCF file metadata. |
| `oxoq_score` | `float` | `minimal`, `with-fpfilter`, `with-fpfilter.with-somaticscore` | The oxo Q score from Picard. |
| `drop_somatic_score` | `int?` | `with-fpfilter.with-somaticscore` | If the somatic score is less than this value, remove it from VCF (default: 25). |
| `min_somatic_score` | `int?` | `with-fpfilter.with-somaticscore` | If the somatic score is less than this value, add filter tag (default: 40). |

#### Custom Data Types

* `vcf_metadata_record` - contains metadata about the samples associated with the input VCF.

| Name | Type | Description |
| ---- | ---- | ----------- |
| `reference_name` | `string?` | Optional reference name (e.g., GRCh38.p2). |
| `patient_barcode` | `string` | Case submitter ID. |
| `case_id` | `string` | Case UUID. |
| `tumor_barcode` | `string` | Tumor aliquot submitter ID. |
| `tumor_aliquot_uuid` | `string` | Tumor aliquot UUID. |
| `tumor_bam_uuid` | `string` | Tumor BAM UUID. |
| `normal_barcode` | `string` | Normal aliquot submitter ID. |
| `normal_aliquot_uuid` | `string` | Normal aliquot UUID. |
| `normal_bam_uuid` | `string` | Normal BAM UUID. |

### Outputs

| Name | Type | Workflow | Description |
| ---- | ---- | -------- | ----------- |
| `dkfz_qc_archive` | `File` | `minimal`, `with-fpfilter`, `with-fpfilter.with-somaticscore` | Tar archive of DKFZ qc metrics. |
| `dtoxog_archive` | `File` | `minimal`, `with-fpfilter`, `with-fpfilter.with-somaticscore` | Tar archive of dtoxog metrics. |
| `final_vcf` | `File` | all | Filtered, formatted, and tabix-indexed VCF file. |

