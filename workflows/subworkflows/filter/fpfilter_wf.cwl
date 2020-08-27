cwlVersion: v1.0
class: Workflow
id: fpfilter_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement

inputs:
  input_vcf: File
  input_bam: File
  input_bam_index: File
  uuid: string
  reference_sequence: File
  reference_sequence_index: File
  sample:
    type: string?
    default: TUMOR

outputs:
  fpfilter_vcf: 
    type: File
    outputSource: fpfilter/vcf_out

steps:
  format:
    run: ../../../tools/picard_vcf_format_converter.cwl
    in:
      input_vcf: input_vcf 
      output_filename:
        source: uuid
        valueFrom: $(self + '.fmt.vcf')
    out: [ output_file ]

  fpfilter:
    run: ../../../tools/fpfilter.cwl
    in:
      vcf_file: format/output_file
      input_bam: input_bam
      input_bam_index: input_bam_index
      reference_sequence: reference_sequence
      reference_sequence_index: reference_sequence_index
      output_filename:
        source: uuid
        valueFrom: $(self + '.fpfilter.vcf')
      sample: sample 
    out: [ vcf_out ]
