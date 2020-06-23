cwlVersion: v1.0
class: Workflow
id: format_input_vcf_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  input_vcf: File
  uuid: string
  sequence_dictionary: File

outputs:
  snv_vcf:
    type: File
    outputSource: split/output_snv_file

  indel_vcf:
    type: File
    outputSource: split/output_indel_file

steps:
  allele_check:
    run: ../../../tools/RemoveNonStandardVariants.cwl
    in:
      input_vcf: input_vcf
      output_filename:
        source: uuid
        valueFrom: "$(self + '.dropnonstandard.vcf.gz')"
    out: [ output_file ]

  format:
    run: ../../../tools/PicardVcfFormatConverter.cwl
    in:
      input_vcf: allele_check/output_file
      output_filename:
        source: uuid
        valueFrom: "$(self + '.fmt.vcf.gz')"
    out: [ output_file ]

  split:
    run: ../../../tools/PicardSplitVcfs.cwl
    in:
      input_vcf: format/output_file
      sequence_dictionary: sequence_dictionary 
      snv_filename:
        source: uuid
        valueFrom: "$(self + '.snv.vcf')"
      indel_filename:
        source: uuid
        valueFrom: "$(self + '.indel.vcf')"
    out: [ output_snv_file, output_indel_file ]
