class: SchemaDefRequirement
types:
  - name: time_record
    type: record
    fields:
      - name: real_time
        type: string
      - name: user_time
        type: float
      - name: system_time
        type: float
      - name: wall_clock
        type: float
      - name: maximum_resident_set_size
        type: int
      - name: percent_of_cpu
        type: string
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
