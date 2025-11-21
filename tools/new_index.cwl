class: CommandLineTool
cwlVersion: v1.0
id: htslib
requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/htslib:{{ htslib }}"
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
  index_file:
    type: File
    outputBinding:
      glob: '*tbi'

baseCommand: []
arguments:
  - position: 0
    shellQuote: false
    valueFrom: >-
      tabix -p vcf $(inputs.input_file.path)
