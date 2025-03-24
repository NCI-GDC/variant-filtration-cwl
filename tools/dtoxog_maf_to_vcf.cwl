cwlVersion: v1.0
class: CommandLineTool
id: dtoxog_maf_to_vcf
requirements:
  - class: DockerRequirement
    dockerPull: {{ docker_repo }}/variant-filtration-tool:{{ variant-filtration-tool }}
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.reference_fasta)
      - $(inputs.reference_index)
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    tmpdirMin: $(file_size_multiplier(inputs.input_maf, 3))
    outdirMin: $(file_size_multiplier(inputs.input_maf, 3))

doc: |
    Extracts results from DToxoG MAF into a minimal tabix indexed VCF 

inputs:
  input_maf:
    type: File
    doc: Absolute filename of input full MAF annotated file from dtoxog 
    inputBinding:
      position: 0 

  reference_fasta:
    type: File
    doc: the reference fasta file
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

  reference_index:
    type: File
    doc: the faidx file

  output_filename:
    type: string
    doc: filename of output vcf file (must end with .gz extension)
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

baseCommand: [dtoxog-maf-to-vcf]
