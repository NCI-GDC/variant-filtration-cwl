cwlVersion: v1.0
class: CommandLineTool
id: format_vcf_header 
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

doc: Format VCF header for GDC 

inputs:
  input_vcf:
    type: File
    inputBinding:
      position: 1 

  output_vcf:
    type: string
    doc: output basename of vcf 
    inputBinding:
      position: 2 

  patient_barcode:
    type: string
    inputBinding:
      position: 3

  case_id:
    type: string
    inputBinding:
      position: 4

  tumor_barcode:
    type: string
    inputBinding:
      position: 5

  tumor_aliquot_uuid:
    type: string
    inputBinding:
      position: 6

  tumor_bam_uuid:
    type: string
    inputBinding:
      position: 7

  normal_barcode:
    type: string
    inputBinding:
      position: 8

  normal_aliquot_uuid:
    type: string
    inputBinding:
      position: 9

  normal_bam_uuid:
    type: string
    inputBinding:
      position: 10

  reference_name:
    type: string?
    default: GRCh38.d1.vd1.fa
    inputBinding:
      prefix: -r
      position: 0

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [format-gdc-vcf]
