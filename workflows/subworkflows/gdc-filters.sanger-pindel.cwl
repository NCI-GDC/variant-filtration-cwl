cwlVersion: v1.0
class: Workflow
id: gdc_filters_sanger_pindel_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../../tools/schemas.cwl

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
    type: "../../tools/schemas.cwl#vcf_metadata_record"
 
outputs:
  final_vcf:
    type: File
    outputSource: vcf_convert/output_file

steps:
  firstUpdate:
    run: ../../tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: input_vcf
      sequence_dictionary: full_ref_dictionary
      output_filename:
        source: file_prefix 
        valueFrom: "$(self + '.first.dict.vcf')"
    out: [ output_file ]

  format_sanger_pindel:
    run: ../../tools/format_sanger_pindel_vcf.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        source: file_prefix 
        valueFrom: "$(self + '.sanger_pindel_format.vcf.gz')"
    out: [ output_file ]

  allele_check:
    run: ../../tools/filter_nonstandard_variants.cwl
    in:
      input_vcf: format_sanger_pindel/output_file 
      output_filename:
        source: file_prefix 
        valueFrom: "$(self + '.dropnonstandard.vcf.gz')"
    out: [ output_file ]

  update_dictionary:
    run: ../../tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: allele_check/output_file 
      sequence_dictionary: main_ref_dictionary
      output_filename:
        source: file_prefix 
        valueFrom: $(self + '.main.seqdict.vcf')
    out: [ output_file ]

  contig_filter:
    run: ../../tools/contig_filter.cwl
    in:
      input_vcf: update_dictionary/output_file
      output_vcf:
        source: file_prefix 
        valueFrom: $(self + '.main.seqdict.contigfilter.vcf')
    out: [ output_vcf_file ]

  format_header:
    run: ../../tools/format_vcf_header.cwl
    in:
      input_vcf: contig_filter/output_vcf_file
      output_vcf:
        source: file_prefix 
        valueFrom: $(self + '.main.seqdict.contigfilter.formatted.vcf')
      reference_name:
        source: vcf_metadata
        valueFrom: $(self.reference_name)
      patient_barcode:
        source: vcf_metadata
        valueFrom: $(self.patient_barcode)
      case_id:
        source: vcf_metadata
        valueFrom: $(self.case_id)
      tumor_barcode:
        source: vcf_metadata
        valueFrom: $(self.tumor_barcode)
      tumor_aliquot_uuid:
        source: vcf_metadata
        valueFrom: $(self.tumor_aliquot_uuid)
      tumor_bam_uuid:
        source: vcf_metadata
        valueFrom: $(self.tumor_bam_uuid)
      normal_barcode:
        source: vcf_metadata
        valueFrom: $(self.normal_barcode)
      normal_aliquot_uuid:
        source: vcf_metadata
        valueFrom: $(self.normal_aliquot_uuid)
      normal_bam_uuid:
        source: vcf_metadata
        valueFrom: $(self.normal_bam_uuid)
    out: [ output_vcf_file ]

  vcf_convert:
    run: ../../tools/picard_vcf_format_converter.cwl
    in:
      input_vcf: format_header/output_vcf_file
      output_filename:
        source: file_prefix 
        valueFrom: $(self + '.variant_filtration.vcf.gz')
    out: [ output_file ]
