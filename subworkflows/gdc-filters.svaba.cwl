cwlVersion: v1.0
class: Workflow
id: gdc_filters_svaba_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../tools/schemas.cwl

inputs:
  input_vcf:
    type: File
    doc: The VCF file you want to filter
  file_prefix:
    type: string
    doc: prefix for filenames 
  full_ref_fasta:
    doc: Full reference fasta containing all scaffolds
    type: File
  full_ref_fasta_index:
    doc: Full reference fasta index
    type: File
  full_ref_dictionary:
    doc: Full reference fasta sequence dictionary
    type: File
  main_ref_fasta:
    doc: Main chromosomes only fasta
    type: File
  main_ref_fasta_index:
    doc: Main chromosomes only fasta index
    type: File
  main_ref_dictionary:
    doc: Main chromosomes only fasta sequence dictionary
    type: File
  vcf_metadata:
    doc: VCF metadata record
    type: "../tools/schemas.cwl#vcf_metadata_record"
  oxoq_score:
    doc: oxoq score from picard
    type: float
 
outputs:
  final_vcf:
    type: File
    outputSource: formatFinalWorkflow/processed_vcf

steps:
  firstUpdate:
    run: ../tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: input_vcf
      sequence_dictionary: full_ref_dictionary
      output_filename:
        source: file_prefix 
        valueFrom: "$(self + '.first.dict.vcf')"
    out: [ output_file ]

  formatSvABAWorkflow:
    run: ../tools/format_svaba_vcf.cwl
    in:
      input_vcf: firstUpdate/output_file
      output_filename: 
        source: file_prefix 
        valueFrom: "$(self + '.svaba.reheader.vcf')"
    out: [ output_file ]

  formatVcfWorkflow:
    run: ./format/format_input_vcf_wf.cwl
    in:
      input_vcf: formatSvABAWorkflow/output_file
      uuid: file_prefix 
      sequence_dictionary: full_ref_dictionary 
    out: [ snv_vcf, indel_vcf ]

  formatFinalWorkflow:
    run: ./format/merge_and_format_svaba_final_vcfs_wf.cwl
    in:
      input_snp_vcf: formatVcfWorkflow/snv_vcf
      input_indel_vcf: formatVcfWorkflow/indel_vcf
      full_reference_sequence_dictionary: full_ref_dictionary
      main_reference_sequence_dictionary: main_ref_dictionary
      vcf_metadata: vcf_metadata
      uuid: file_prefix 
    out: [ processed_vcf ]
