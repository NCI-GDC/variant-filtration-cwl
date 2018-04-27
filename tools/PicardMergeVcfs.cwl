#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "Picard MergeVcfs"
cwlVersion: v1.0
doc: |
    Merge VCF files 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:3839a594cab6b8576e76124061cf222fb3719f20
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type:
      type: array
      items: File
      inputBinding:
        prefix: I=
        separate: false
    doc: "input vcf file"

  sequence_dictionary:
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      prefix: "SEQUENCE_DICTIONARY="
      separate: false

  output_filename:
    type: string
    doc: output basename of merged 
    inputBinding:
      prefix: OUTPUT=
      separate: false

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - ".tbi"

baseCommand: [java, -Xmx4G, -jar, /opt/picard.jar, MergeVcfs]
