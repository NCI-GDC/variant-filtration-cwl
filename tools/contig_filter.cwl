class: CommandLineTool
cwlVersion: v1.0
id: gdc_filtration_tools_filter_contigs 
doc: |
    Reduce VCF to contigs present in header

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:6e5e350c1b9867b2271e209ece163f1c7b0eb4d1
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      position: 0 

  output_vcf:
    type: string
    doc: output basename of vcf 
    inputBinding:
      position: 1

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [ gdc-filtration-tools, filter-contigs ] 
