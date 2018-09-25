#!/usr/bin/env cwl-runner

class: CommandLineTool
label: Formats pindel vcf 
cwlVersion: v1.0
doc: |
    Formats Pindel VCFs 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:920c0615f6df7c4bbb7adc1f0e82606bd53e5277 
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: input vcf file
    inputBinding:
      prefix: --input_vcf

  output_filename:
    type: string
    doc: output basename of output file
    inputBinding:
        prefix: --output_vcf

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - ".tbi"
    doc: Formatted VCF file

baseCommand: [python3, /variant-filtration-tool/PindelVcfFormatter.py] 
