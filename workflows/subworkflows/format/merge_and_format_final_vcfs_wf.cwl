cwlVersion: v1.0
class: Workflow
id: merge_and_format_final_vcf_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - $import: ../../../tools/schemas.cwl

inputs:
  input_snp_vcf: File
  input_indel_vcf: File
  full_reference_sequence_dictionary: File
  main_reference_sequence_dictionary: File
  vcf_metadata: "../../../tools/schemas.cwl#vcf_metadata_record"
  uuid: string

outputs:
  processed_vcf:
    type: File
    outputSource: vcf_convert/output_file

steps:
  merge_vcfs:
    run: ../../../tools/picard_merge_vcfs.cwl
    in:
      input_vcf: [ input_snp_vcf, input_indel_vcf ] 
      sequence_dictionary: full_reference_sequence_dictionary
      output_filename:
        source: uuid
        valueFrom: $(self + '.merged.vcf.gz')
    out: [ output_vcf_file ]

  update_dictionary:
    run: ../../../tools/picard_update_sequence_dictionary.cwl
    in:
      input_vcf: merge_vcfs/output_vcf_file
      sequence_dictionary: main_reference_sequence_dictionary 
      output_filename:
        source: uuid
        valueFrom: $(self + '.merged.seqdict.vcf')
    out: [ output_file ]

  contig_filter:
    run: ../../../tools/contig_filter.cwl
    in:
      input_vcf: update_dictionary/output_file
      output_vcf:
        source: uuid
        valueFrom: $(self + '.merged.seqdict.contigfilter.vcf')
    out: [ output_vcf_file ]

  format_header:
    run: ../../../tools/format_vcf_header.cwl
    in:
      input_vcf: contig_filter/output_vcf_file
      output_vcf:
        source: uuid
        valueFrom: $(self + '.merged.seqdict.contigfilter.vcf')
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
    run: ../../../tools/picard_vcf_format_converter.cwl
    in:
      input_vcf: format_header/output_vcf_file
      output_filename:
        source: uuid
        valueFrom: $(self + '.variant_filtration.vcf.gz')
    out: [ output_file ]
