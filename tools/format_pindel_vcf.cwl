cwlVersion: v1.0
class: CommandLineTool
id: format_pindel_vcf
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:1.0.2
  - class: InlineJavascriptRequirement

doc: Formats GDC WXS Pindel VCFs 

inputs:
  input_vcf:
    type: File
    doc: input vcf file
    inputBinding:
      position: 0 

  output_filename:
    type: string
    doc: output basename of output file
    inputBinding:
        position: 1 

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - ".tbi"
    doc: Formatted VCF file

baseCommand: [format-pindel-vcf]
