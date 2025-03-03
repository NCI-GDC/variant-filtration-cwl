cwlVersion: v1.0
class: CommandLineTool
id: picard_merge_vcfs
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:2.26.10
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 5000

doc: Merge VCF files

inputs:
  input_vcf:
    type: File
    inputBinding:
      prefix: I=
      separate: false

  sequence_dictionary:
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      prefix: SEQUENCE_DICTIONARY=
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

baseCommand: [java, -Xmx4G, -jar, /usr/local/bin/picard.jar, SortVcf]
