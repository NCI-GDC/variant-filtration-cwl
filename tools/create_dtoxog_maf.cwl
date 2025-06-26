cwlVersion: v1.0
class: CommandLineTool
id: create_dtoxog_maf 
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/variant-filtration-tool:{{ variant_filtration_tool }}"
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)

doc: Convert a SNP VCF to the input MAF format required for DToxoG 

inputs:
  input_vcf: 
    type: File
    doc: input SNP VCF file 
    inputBinding:
      position: 0 

  output_filename:
    type: string
    doc: filename of output maf file
    inputBinding:
      position: 1 

  reference_sequence: 
    type: File
    doc: Reference fasta file 
    inputBinding:
      position: 2 
      valueFrom: $(self.basename)

  reference_sequence_index: 
    type: File
    doc: Reference faidx file 

  gatk_oxog_file: 
    type: File
    doc: metrics file from the GATK oxoG metrics tool 
    inputBinding:
      position: 3 

  oxoq_score: 
    type: float 
    doc: extracted OXOQ score 
    inputBinding:
      position: 4 

outputs:
  output_maf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
    doc: The MAF file 

baseCommand: [gdc_filtration_tools, create-dtoxog-maf]
