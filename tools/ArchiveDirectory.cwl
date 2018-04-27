#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    Creates a tar.gz archive of a directory

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:3839a594cab6b8576e76124061cf222fb3719f20
  - class: InlineJavascriptRequirement

inputs:
  input_directory:
    type: Directory
    doc: Path to directory you want to archive
    inputBinding:
      position: 2
      valueFrom: $(self.basename)

outputs:
  output_archive:
    type: File
    outputBinding:
      glob: $(inputs.input_directory.basename + '.tar.gz')
    doc: The archived directory

baseCommand: [tar]

arguments:
  - valueFrom: $(inputs.input_directory.dirname)
    position: 0
    prefix: -C
  - valueFrom: $(inputs.input_directory.basename + '.tar.gz')
    position: 1
    prefix: -hczf
