#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - $import: ../../../tools/schemas.cwl

inputs:
  input_vcf: File
  drop_somatic_score: int?
  min_somatic_score: int?
  uuid: string
  sample:
    type: string?
    default: TUMOR

outputs:
  somaticscore_vcf: 
    type: File
    outputSource: somaticscore_filter/output_vcf_file

steps:
  somaticscore_filter:
    run: ../../../tools/SomaticScoreFilter.cwl
    in:
      input_vcf: input_vcf 
      output_vcf:
        source: uuid
        valueFrom: $(self + '.somaticscore.vcf')
      tumor_sample_name: sample 
      drop_somatic_score: drop_somatic_score
      min_somatic_score: min_somatic_score
    out: [ output_vcf_file ] 
