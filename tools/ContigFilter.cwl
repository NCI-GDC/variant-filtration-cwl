#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "ContigFilter"
cwlVersion: v1.0
doc: |
    Reduce VCF to contigs present in header

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:2.0 
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

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/variant-filtration-tool/FilterContigs.py] 
