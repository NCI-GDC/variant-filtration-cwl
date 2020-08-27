class: CommandLineTool
cwlVersion: v1.0
id: picard_update_sequence_dictionary
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:2.20.0
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 5000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
doc: |
    Updates sequence dictionary in VCF 

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      prefix: "INPUT="
      separate: false

  sequence_dictionary:
    type: File
    doc: sequence dictionary you want to update header with 
    inputBinding:
      prefix: SD= 
      separate: false

  output_filename:
    type: string
    doc: output basename of output file
    inputBinding:
      prefix: "OUTPUT="
      separate: false

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: Updated VCF file 

baseCommand: [java, -Xmx4G, -jar, /usr/local/bin/picard.jar, UpdateVcfSequenceDictionary]
