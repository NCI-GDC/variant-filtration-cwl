cwlVersion: v1.0
class: CommandLineTool
id: fixhead

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-alpine:{{ bio-alpine }}"
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.vcf_file)
        entryname: $(inputs.vcf_file.nameroot)
        writable: true

inputs:
  vcf_file:
    type: File
    inputBinding:
      position: 1

outputs:
  fixed_head_vcf:
    type: File
    outputBinding:
      glob: "*.fixed.header.vcf"

baseCommand: [awk, '/^#CHROM/ {printf("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n");} {print}']

stdout: "$(inputs.vcf_file.nameroot).fixed.header.vcf"

