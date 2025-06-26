cwlVersion: v1.0
class: CommandLineTool
id: pos_filter_for_dkfz
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/variant-filtration-tool:{{ variant_filtration_tool }}"
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))

doc: Reduce SNV VCF to positions that are ok for DKFZ

inputs:
  input_vcf:
    type: File
    doc: "input snp vcf file"
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

baseCommand: [gdc_filtration_tools, position-filter-dkfz]
