cwlVersion: v1.0
class: CommandLineTool
id: fixhead

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "docker.osdc.io/ncigdc/bio-alpine:base"
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

baseCommand: 
  - awk
  - '{gsub(/##FORMAT=<ID=TOR,Number=2,Type=Integer,Description="Other reads \(weak support or insufficient indel breakpoint overlap\) for tiers 1,2">/, "##FORMAT=<ID=TOR,Number=2,Type=Float,Description=\"Other reads (weak support or insufficient indel breakpoint overlap) for tiers 1,2\">"); print}'

stdout: "$(inputs.vcf_file.nameroot).fixed.header.vcf"

