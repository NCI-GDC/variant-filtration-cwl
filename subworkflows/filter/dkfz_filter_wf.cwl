cwlVersion: v1.0
class: Workflow
id: dkfz_filter_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_snp_vcf: File
  bam: File
  bam_index: File
  reference_sequence: File
  reference_sequence_index: File
  uuid: string

outputs:
  dkfz_vcf:
    type: File
    outputSource: dkfz/output_vcf_file

  dkfz_qc_archive:
    type: File
    outputSource: archive_dkfz/output_archive

steps:
  pos_filter:
    run: ../../tools/pos_filter_for_dkfz.cwl
    in:
      input_vcf: input_snp_vcf
      output_vcf:
        source: uuid
        valueFrom: $(self + '.snp.posFiltered.vcf')
    out: [ output_vcf_file ]

  dkfz:
    run: ../../tools/dkfz_bias_filter.cwl
    in:
      input_vcf: pos_filter/output_vcf_file
      input_bam: bam
      input_bam_index: bam_index
      reference_sequence: reference_sequence 
      reference_sequence_index: reference_sequence_index 
      uuid: uuid
    out: [ output_vcf_file, output_qc_folder ]
      
  archive_dkfz:
    run: ../../tools/archive_directory.cwl
    in:
      input_directory: dkfz/output_qc_folder
    out: [ output_archive ]
