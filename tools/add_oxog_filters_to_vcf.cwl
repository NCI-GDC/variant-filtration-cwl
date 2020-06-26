class: CommandLineTool
cwlVersion: v1.0
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

doc: Annotates VCF with D-ToxoG results 

inputs:
  input_vcf:
    type: File
    doc: Absolute filename of input full SNV VCF file 
    inputBinding:
      position: 0 

  input_dtoxog:
    type: File
    doc: Absolute filename of annotated minimal VCF from DToxoG 
    inputBinding:
      position: 1 
    secondaryFiles:
      - ".tbi"

  output_filename:
    type: string
    doc: filename of output vcf file (should end with .gz)
    inputBinding:
      position: 2 

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: The tabix indexed output file
    secondaryFiles:
        - ".tbi" 

baseCommand: [gdc-filtration-tools, add-oxog-filters]
