class: SchemaDefRequirement
types:
  - name: vcf_metadata_record
    type: record
    fields:
      - name: reference_name
        type: string?
      - name: patient_barcode
        type: string
      - name: case_id
        type: string
      - name: tumor_barcode
        type: string
      - name: tumor_aliquot_uuid
        type: string
      - name: tumor_bam_uuid
        type: string
      - name: normal_barcode
        type: string
      - name: normal_aliquot_uuid
        type: string
      - name: normal_bam_uuid
        type: string
