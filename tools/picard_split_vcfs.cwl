cwlVersion: v1.0
class: CommandLineTool
id: picard_split_vcfs
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/picard:{{ picard }}"
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 5000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))

doc: |
    Split a VCF file into InDels and SNVs

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      prefix: "INPUT="
      separate: false
    secondaryFiles:
      - ".tbi"

  sequence_dictionary:
    type: File
    doc: reference sequence dictionary file
    inputBinding:
      prefix: "SEQUENCE_DICTIONARY="
      separate: false

  snv_filename:
    type: string
    default: snv.vcf
    doc: output basename of SNV file
    inputBinding:
      prefix: "SNP_OUTPUT="
      separate: false

  indel_filename:
    type: string
    default: indel.vcf
    doc: output basename of INDEL file
    inputBinding:
      prefix: "INDEL_OUTPUT="
      separate: false

outputs:
  output_snv_file:
    type: File
    outputBinding:
      glob: $(inputs.snv_filename)
    doc: SNV VCF File
    secondaryFiles:
      - ".idx"

  output_indel_file:
    type: File
    outputBinding:
      glob: $(inputs.indel_filename)
    doc: INDEL VCF File
    secondaryFiles:
      - ".idx"

baseCommand: [java, -Xmx4G, -jar, /usr/local/bin/picard.jar, SplitVcfs, STRICT=false]
