class: CommandLineTool
cwlVersion: v1.0
id: bgzip
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/tabix:{{ tabix }}"
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.input_file)
        entryname: $(inputs.input_file.basename)
  - class: ResourceRequirement
    coresMax: 1

inputs:
  input_file:
    type: File

outputs:
  compressed_file:
    type: File
    outputBinding:
      glob: '*gz'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      bgzip $(inputs.input_file.path) &&
      tabix $(inputs.input_file.path).gz
