#!/usr/bin/env cwl-runner

class: CommandLineTool
label: Drops non-standard VCF alleles
cwlVersion: v1.0
doc: |
    Filters (REMOVES!) rows from VCF with non-standard alleles

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:3839a594cab6b8576e76124061cf222fb3719f20
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

baseCommand: [/opt/gdc-biasfilter-tool/RemoveNonStandardVariants.py]
