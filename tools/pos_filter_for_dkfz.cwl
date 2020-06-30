cwlVersion: v1.0
class: CommandLineTool
id: pos_filter_for_dkfz
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:6e5e350c1b9867b2271e209ece163f1c7b0eb4d1
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

baseCommand: [gdc-filtration-tools, position-filter-dkfz]
