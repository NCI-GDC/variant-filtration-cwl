cwlVersion: v1.0
class: Workflow
id: stage_inputs_wf
requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  bioclient_config: File
  dnaseq_metrics_id: string
  vcf_id: string
  full_ref_dictionary_id: string
  main_ref_dictionary_id: string

outputs:
  dnaseq_metrics_db:
    type: File
    outputSource: sqlite_dl/output

  input_vcf:
    type: File
    outputSource: vcf_dl/output

  full_ref_dictionary:
    type: File
    outputSource: full_ref_dict_dl/output

  main_ref_dictionary:
    type: File
    outputSource: main_ref_dict_dl/output

steps:
  sqlite_dl:
    run: ../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: dnaseq_metrics_id
    out: [ output ]

  vcf_dl:
    run: ../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: vcf_id
    out: [ output ]

  full_ref_dict_dl:
    run: ../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: full_ref_dictionary_id
    out: [ output ]

  main_ref_dict_dl:
    run: ../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: main_ref_dictionary_id
    out: [ output ]
