cwlVersion: v1.0
class: CommandLineTool
label: filter_somatic_score 
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:920c0615f6df7c4bbb7adc1f0e82606bd53e5277 
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 2))

doc: |
    Filter somaticsniper VCFs to remove very low ssc and tag low ssc 

inputs:

  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      position: 3 

  output_vcf:
    type: string
    doc: output basename of vcf 
    inputBinding:
      position: 4

  tumor_sample_name:
    type: string?
    default: TUMOR
    doc: Tumor sample name in VCF
    inputBinding:
      prefix: --tumor-sample-name
      position: 0

  drop_somatic_score:
    type: int?
    default: 25
    inputBinding:
      prefix: --drop-somatic-score
      position: 1

  min_somatic_score:
    type: int?
    default: 40
    inputBinding:
      prefix: --min-somatic-score
      position: 2

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [gdc-filtration-tools, filter-somatic-score]
