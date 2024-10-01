cwlVersion: v1.0
class: Workflow
id: gpas_variant_filtration_svaba_wf
requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - $import: ../tools/schemas.cwl

inputs:
  project_id:
    type: string?
    doc: GDC project id used for output filenames
  experimental_strategy:
    type: string
    doc: GDC experimental strategy used for output filenames
  caller_id:
    type: string
    doc: GDC caller id used for output filenames
  bioclient_config:
    type: File
  upload_bucket:
    type: string
  input_dnaseq_metrics_db:
    type: string
    doc: The dnaseq wf metrics sqlite db
  input_vcf_id:
    type: string
    doc: The VCF file ID you want to filter
  input_vcf_index_id:
    type: string
    doc: The VCF file index ID
  sqlite_input_state:
    type: string
    doc: The value for input_state column to filter
  job_uuid:
    type: string
    doc: UUID to use for the job
  full_ref_fasta_id:
    doc: Full reference fasta containing all scaffolds
    type: string
  full_ref_fasta_index_id:
    doc: Full reference fasta index
    type: string
  full_ref_dictionary_id:
    doc: Full reference fasta sequence dictionary
    type: string
  main_ref_fasta_id:
    doc: Main chromosomes only fasta
    type: string
  main_ref_fasta_index_id:
    doc: Main chromosomes only fasta index
    type: string
  main_ref_dictionary_id:
    doc: Main chromosomes only fasta sequence dictionary
    type: string
  reference_name:
    type: string
    default: "GRCh38.d1.vd1.fa"
    doc: The string to use for the reference name in the VCF header
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
  tumor_bam_index_uuid:
    type: string
  normal_aliquot_submitter_id:
    type: string
  normal_aliquot_id:
    type: string
  normal_bam_uuid:
    type: string

outputs:
  filtered_vcf_id:
    type: string
    outputSource: uuid_vcf/output

  filtered_vcf_index_id:
    type: string
    outputSource: uuid_vcf_index/output

  tar_archive_id:
    type: string
    outputSource: uuid_archive/output

steps:
  make_vcf_record:
    run: ../tools/make_vcf_record.cwl
    in:
      reference_name: reference_name
      case_submitter_id: case_submitter_id
      case_id: case_id
      tumor_aliquot_submitter_id: tumor_aliquot_submitter_id
      tumor_aliquot_id: tumor_aliquot_id
      tumor_bam_uuid: tumor_bam_uuid
      normal_aliquot_submitter_id: normal_aliquot_submitter_id
      normal_aliquot_id: normal_aliquot_id
      normal_bam_uuid: normal_bam_uuid
    out: [output]

  prepare_files:
    run: ../subworkflows/utils/stage_inputs_wf.cwl
    in:
      bioclient_config: bioclient_config
      dnaseq_metrics_id: input_dnaseq_metrics_db
      tumor_bam_id: tumor_bam_uuid
      tumor_bam_index_id: tumor_bam_index_uuid
      vcf_id: input_vcf_id
      full_ref_fasta_id: full_ref_fasta_id
      full_ref_fasta_index_id: full_ref_fasta_index_id
      full_ref_dictionary_id: full_ref_dictionary_id
      main_ref_fasta_id: main_ref_fasta_id
      main_ref_fasta_index_id: main_ref_fasta_index_id
      main_ref_dictionary_id: main_ref_dictionary_id
    out:
      - dnaseq_metrics_db
      - tumor_bam
      - tumor_bam_index
      - input_vcf
      - full_ref_fasta
      - full_ref_fai
      - full_ref_dictionary
      - main_ref_fasta
      - main_ref_fai
      - main_ref_dictionary

  extract_oxoq:
    run: ../tools/extract_oxoq_from_sqlite.cwl
    in:
      db_file: prepare_files/dnaseq_metrics_db
      input_state: sqlite_input_state
    out: [oxoq_score, oxoq_score_file]

  get_filename_prefix:
    run: ../tools/make_file_prefix.cwl
    in:
      project_id: project_id
      caller_id: caller_id
      job_id: job_uuid
      experimental_strategy: experimental_strategy
    out: [ output ]

  run_filter:
    run: ../subworkflows/gdc-filters.svaba.cwl
    in:
      input_vcf: prepare_files/input_vcf
      tumor_bam: prepare_files/tumor_bam
      tumor_bam_index: prepare_files/tumor_bam_index
      file_prefix: get_filename_prefix/output
      full_ref_fasta: prepare_files/full_ref_fasta
      full_ref_fasta_index: prepare_files/full_ref_fai
      full_ref_dictionary: prepare_files/full_ref_dictionary
      main_ref_fasta: prepare_files/main_ref_fasta
      main_ref_fasta_index: prepare_files/main_ref_fai
      main_ref_dictionary: prepare_files/main_ref_dictionary
      vcf_metadata: make_vcf_record/output
      oxoq_score: extract_oxoq/oxoq_score
    out: [ final_vcf ]

  make_archive:
    run: ../tools/archive_list.cwl
    in:
      input_files:
        - extract_oxoq/oxoq_score_file
      output_archive_name:
        source: get_filename_prefix/output
        valueFrom: $(self + '.variant_filtration_archive.tar.gz')
    out: [ output_archive ]

  upload_vcf:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, run_filter/final_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: run_filter/final_vcf
    out: [output]

  upload_vcf_index:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, run_filter/final_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: run_filter/final_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  upload_archive:
    run: ../tools/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, make_archive/output_archive]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: make_archive/output_archive
    out: [output]

  uuid_vcf:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_vcf/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_vcf_index:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_vcf_index/output
      key:
        valueFrom: 'did'
    out: [output]

  uuid_archive:
    run: ../tools/emit_json_value.cwl
    in:
      input: upload_archive/output
      key:
        valueFrom: 'did'
    out: [output]
