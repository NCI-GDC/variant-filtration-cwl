cwlVersion: v1.0
class: CommandLineTool
id: bcftools_sort_vcf
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bcftools:{{ bcftools }}"
  - class: ResourceRequirement
    coresMin: 1 
    ramMin: 1000

inputs:

  input_vcf:
    type: File
    secondaryFiles: [^.gz.tbi]
    inputBinding:
      position: 2

  output_type:
    type: string
    default: z
    inputBinding:
      prefix: -O
      position: 7

#  output_filename:
#    type: string

outputs:
  sorted_vcf:
    type: File
    outputBinding:
      glob: $("sorted." + inputs.input_vcf.basename)

baseCommand: [bcftools, sort]

arguments:
  - position: 3
    prefix: -o 
    valueFrom: $("sorted." + inputs.input_vcf.basename)
