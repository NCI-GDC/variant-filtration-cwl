#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - $import: schemas.cwl

class: ExpressionTool

inputs:
  reference_name:
    type: string

  case_submitter_id:
    type: string 

  case_id:
    type: string 

  tumor_aliquot_submitter_id:
    type: string 

  tumor_aliquot_id:
    type: string 

  tumor_bam_uuid:
    type: string 

  normal_aliquot_submitter_id:
    type: string 

  normal_aliquot_id:
    type: string 

  normal_bam_uuid:
    type: string 


outputs:
  output: "schemas.cwl#vcf_metadata_record"

expression: |
  ${
    return({'output': 
      {
        'reference_name': inputs.reference_name,
        'patient_barcode': inputs.case_submitter_id,
        'case_id': inputs.case_id,
        'tumor_barcode': inputs.tumor_aliquot_submitter_id,
        'tumor_aliquot_uuid': inputs.tumor_aliquot_id,
        'tumor_bam_uuid': inputs.tumor_bam_uuid,
        'normal_barcode': inputs.normal_aliquot_submitter_id,
        'normal_aliquot_uuid': inputs.normal_aliquot_id,
        'normal_bam_uuid': inputs.normal_bam_uuid
      }});
  }
