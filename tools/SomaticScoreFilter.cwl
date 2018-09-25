#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "SomaticScoreFilter"
cwlVersion: v1.0
doc: |
    Filter somaticsniper VCFs to remove very low ssc and tag low ssc 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:920c0615f6df7c4bbb7adc1f0e82606bd53e5277 
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      prefix: --input_vcf

  output_vcf:
    type: string
    doc: output basename of vcf 
    inputBinding:
      prefix: --output_vcf

  tumor_sample_name:
    type: string?
    default: TUMOR
    doc: Tumor sample name in VCF
    inputBinding:
      prefix: --tumor_sample_name

  drop_somatic_score:
    type: int?
    default: 25
    inputBinding:
      prefix: --drop_somatic_score

  min_somatic_score:
    type: int?
    default: 40
    inputBinding:
      prefix: --min_somatic_score

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [python3, /variant-filtration-tool/SomaticScoreFilter.py]
