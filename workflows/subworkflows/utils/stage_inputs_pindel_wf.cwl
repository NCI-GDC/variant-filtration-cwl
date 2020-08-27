cwlVersion: v1.0
class: Workflow
id: stage_inputs_pindel_wf
requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  bioclient_config: File
  vcf_id: string
  full_ref_fasta_id: string
  full_ref_fasta_index_id: string
  full_ref_dictionary_id: string
  main_ref_fasta_id: string
  main_ref_fasta_index_id: string
  main_ref_dictionary_id: string

outputs:
  input_vcf:
    type: File
    outputSource: vcf_dl/output

  full_ref_fasta:
    type: File
    outputSource: full_ref_dl/output

  full_ref_fai:
    type: File
    outputSource: full_ref_fai_dl/output

  full_ref_dictionary:
    type: File
    outputSource: full_ref_dict_dl/output

  main_ref_fasta:
    type: File
    outputSource: main_ref_dl/output

  main_ref_fai:
    type: File
    outputSource: main_ref_fai_dl/output

  main_ref_dictionary:
    type: File
    outputSource: main_ref_dict_dl/output

steps:
  vcf_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: vcf_id
    out: [ output ]

  full_ref_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: full_ref_fasta_id 
    out: [ output ]

  full_ref_fai_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: full_ref_fasta_index_id 
    out: [ output ]

  full_ref_dict_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: full_ref_dictionary_id 
    out: [ output ]

  main_ref_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: main_ref_fasta_id 
    out: [ output ]

  main_ref_fai_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: main_ref_fasta_index_id 
    out: [ output ]

  main_ref_dict_dl:
    run: ../../../tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: main_ref_dictionary_id 
    out: [ output ]
