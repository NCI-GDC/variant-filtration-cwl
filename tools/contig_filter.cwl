class: CommandLineTool
cwlVersion: v1.0
id: gdc_filtration_tools_filter_contigs 
doc: |
    Reduce VCF to contigs present in header

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/variant-filtration-tool:{{ variant_filtration_tool }}"
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

baseCommand: [gdc_filtration_tools, filter-contigs]
