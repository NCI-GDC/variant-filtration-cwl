#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "FormatVcfHeader"
cwlVersion: v1.0
doc: |
    Format VCF header for GDC 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:2.0 
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      prefix: --input_vcf

  output_vcf:
    type: string
    doc: output basename of vcf 
    inputBinding:
      prefix: --output_vcf

  reference_name:
    type: string?
    default: GRCh38.d1.vd1.fa
    inputBinding:
      prefix: --reference_name

  patient_barcode:
    type: string
    inputBinding:
      prefix: --patient_barcode

  case_id:
    type: string
    inputBinding:
      prefix: --case_id

  tumor_barcode:
    type: string
    inputBinding:
      prefix: --tumor_barcode

  tumor_aliquot_uuid:
    type: string
    inputBinding:
      prefix: --tumor_aliquot_uuid

  tumor_bam_uuid:
    type: string
    inputBinding:
      prefix: --tumor_bam_uuid

  normal_barcode:
    type: string
    inputBinding:
      prefix: --normal_barcode

  normal_aliquot_uuid:
    type: string
    inputBinding:
      prefix: --normal_aliquot_uuid

  normal_bam_uuid:
    type: string
    inputBinding:
      prefix: --normal_bam_uuid

  caller_workflow_id:
    type: string
    inputBinding:
      prefix: --caller_workflow_id

  caller_workflow_name:
    type: string
    inputBinding:
      prefix: --caller_workflow_name

  caller_workflow_description:
    type: string?
    inputBinding:
      prefix: --caller_workflow_description

  caller_workflow_version:
    type: string?
    default: "1.0"
    inputBinding:
      prefix: --caller_workflow_version

  annotation_workflow_id:
    type: string
    inputBinding:
      prefix: --annotation_workflow_id

  annotation_workflow_name:
    type: string
    inputBinding:
      prefix: --annotation_workflow_name

  annotation_workflow_description:
    type: string?
    inputBinding:
      prefix: --annotation_workflow_description

  annotation_workflow_version:
    type: string?
    default: "1.0"
    inputBinding:
      prefix: --annotation_workflow_version

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_vcf)

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/variant-filtration-tool/FormatVcfHeaderForGDC.py]
