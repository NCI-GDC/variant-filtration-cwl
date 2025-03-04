cwlVersion: v1.0
class: Workflow
id: gdc_filters_minimal_wf
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
  tumor_bam:
    type: File
    doc: The tumor BAM file
  tumor_bam_index:
    type: File
    doc: The tumor BAI file
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
  dkfz_qc_archive:
    type: File
    outputSource: dkfzWorkflow/dkfz_qc_archive

  dtoxog_archive:
    type: File
    outputSource: dtoxogWorkflow/dtoxog_archive

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

  formatVcfWorkflow:
    run: ./format/format_input_vcf_wf.cwl
    in:
      input_vcf: firstUpdate/output_file
      uuid: file_prefix 
      sequence_dictionary: full_ref_dictionary 
    out: [ snv_vcf, indel_vcf ]

  add_gt:
   run: ../tools/add_gt.cwl
   in:
     vcf_file: formatVcfWorkflow/snv_vcf
   out: [ fixed_vcf ]

  add_format:
   run: ../tools/fix_header.cwl
   in:
     vcf_file: add_gt/fixed_vcf
   out: [ fixed_head_vcf ]

  add_gt_indel:
   run: ../tools/add_gt.cwl
   in:
     vcf_file: formatVcfWorkflow/indel_vcf
   out: [ fixed_vcf ]

  add_format_indel:
   run: ../tools/fix_header.cwl
   in:
     vcf_file: add_gt_indel/fixed_vcf
   out: [ fixed_head_vcf ]

  dkfzWorkflow:
    run: ./filter/dkfz_filter_wf.cwl
    in:
      input_snp_vcf: add_format/fixed_head_vcf
      bam: tumor_bam
      bam_index: tumor_bam_index
      reference_sequence: full_ref_fasta
      reference_sequence_index: full_ref_fasta_index
      uuid: file_prefix 
    out: [ dkfz_vcf, dkfz_qc_archive ]

  dtoxogWorkflow:
    run: ./filter/dtoxog_filter_wf.cwl
    in:
      input_snp_vcf: dkfzWorkflow/dkfz_vcf
      oxoq_score: oxoq_score
      bam: tumor_bam
      bam_index: tumor_bam_index
      full_reference_sequence: full_ref_fasta
      full_reference_sequence_index: full_ref_fasta_index
      full_reference_sequence_dictionary: full_ref_dictionary
      main_reference_sequence: main_ref_fasta
      main_reference_sequence_index: main_ref_fasta_index
      main_reference_sequence_dictionary: main_ref_dictionary
      uuid: file_prefix 
    out: [ dtoxog_archive, dtoxog_vcf ] 

  head_snp:
    run: ../tools/fix_header_int.cwl
    in:
      vcf_file: dtoxogWorkflow/dtoxog_vcf
    out: [fixed_head_vcf]

  head_indel:
    run: ../tools/fix_header_int.cwl
    in:
      vcf_file: add_format_indel/fixed_head_vcf
    out: [fixed_head_vcf]

  sort_snp:
    run: ../tools/picard_sort.cwl
    in:
      input_vcf: head_snp/fixed_head_vcf
      output_filename: 
        source: file_prefix
        valueFrom: $(self + '.sorted.vcf')
      sequence_dictionary: full_ref_dictionary
    out: [output_vcf_file]

  sort_indel:
    run: ../tools/picard_sort.cwl
    in:
      input_vcf: head_indel/fixed_head_vcf
      output_filename: 
        source: file_prefix
        valueFrom: $(self + '.sorted.indel.vcf')
      sequence_dictionary: full_ref_dictionary
    out: [output_vcf_file]

  formatFinalWorkflow:
    run: ./format/merge_and_format_final_vcfs_wf.cwl
    in:
      input_snp_vcf: sort_snp/output_vcf_file
      input_indel_vcf: sort_indel/output_vcf_file
      full_reference_sequence_dictionary: full_ref_dictionary
      main_reference_sequence_dictionary: main_ref_dictionary
      vcf_metadata: vcf_metadata
      uuid: file_prefix 
    out: [ processed_vcf ]
