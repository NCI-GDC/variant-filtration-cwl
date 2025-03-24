cwlVersion: v1.0
class: CommandLineTool
id: addgt

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-alpine:{{ bio-alpine }}"
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.vcf_file)
        entryname: $(inputs.vcf_file.basename)
        writable: true

inputs:
  vcf_file:
    type: File
    inputBinding:
      position: 1

outputs:
  fixed_vcf:
    type: File
    outputBinding:
      glob: "*.fixed.vcf"

baseCommand: [awk, '-F', '\t', '-v', 'OFS=\t', "{ if(/^#/){print}else{$9=\"GT:\"$9;$10=\"0/1:\"$10;print}}"]

stdout: "$(inputs.vcf_file.basename).fixed.vcf"
