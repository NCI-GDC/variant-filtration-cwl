#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    A Docker container for the CreateOxogIntervalsFromVcf.py tool

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:0.4
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: Absolute filename of input SNP vcf file
    inputBinding:
      position: 0

  output_filename:
    type: string
    doc: filename of output interval file
    inputBinding:
      position: 1

outputs:
  output_interval_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: The interval list file

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/gdc-biasfilter-tool/CreateOxogIntervalsFromVcf.py]
