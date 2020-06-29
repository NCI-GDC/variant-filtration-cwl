cwlVersion: v1.0
class: CommandLineTool
id: filter_nonstandard_variants 
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:1e8972e6ec013f25d95d4802c6d02cd92c31383b
  - class: InlineJavascriptRequirement
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))

doc: |
    Filters (REMOVES!) rows from VCF with non-standard alleles

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

baseCommand: [gdc-filtration-tools, filter-nonstandard-variants]
