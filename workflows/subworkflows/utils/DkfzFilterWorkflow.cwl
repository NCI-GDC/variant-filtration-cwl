#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - $import: ../../../tools/schemas.cwl

inputs:
  input_snp_vcf: File
  bam: File
  bam_index: File
  reference_sequence: File
  reference_sequence_index: File
  uuid: string

outputs:
  dkfz_vcf:
    type: File
    outputSource: dkfz/output_vcf_file

  dkfz_qc_archive:
    type: File
    outputSource: archive_dkfz/output_archive

  dkfz_time_record:
    type: "../../../tools/schemas.cwl#time_record"
    outputSource: dkfz/time_record

steps:
  pos_filter:
    run: ../../../tools/PosFilterForDkfz.cwl
    in:
      input_vcf: input_snp_vcf
      output_vcf:
        source: uuid
        valueFrom: $(self + '.snp.posFiltered.vcf')
    out: [ output_vcf_file ]

  dkfz:
    run: ../../../tools/DKFZBiasFilter.cwl
    in:
      input_vcf: pos_filter/output_vcf_file
      input_bam: bam
      input_bam_index: bam_index
      reference_sequence: reference_sequence 
      reference_sequence_index: reference_sequence_index 
      uuid: uuid
    out: [ output_vcf_file, output_qc_folder, time_record ]
      
  archive_dkfz:
    run: ../../../tools/ArchiveDirectory.cwl
    in:
      input_directory: dkfz/output_qc_folder
    out: [ output_archive ]
