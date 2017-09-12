#!/usr/bin/env cwl-runner

class: CommandLineTool
label: Drops non-standard VCF alleles
cwlVersion: v1.0
doc: |
    Filters (REMOVES!) rows from VCF with non-standard alleles

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:0.4
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: input vcf file
    inputBinding:
      position: 0

  output_filename:
    type: string
    doc: output basename of output file
    inputBinding:
        position: 1

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: Filtered VCF file

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/gdc-biasfilter-tool/RemoveNonStandardVariants.py]
