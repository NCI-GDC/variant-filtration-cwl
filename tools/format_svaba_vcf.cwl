cwlVersion: v1.0
class: CommandLineTool
id: format_pindel_vcf
requirements:
  - class: DockerRequirement
    dockerPull: docker.osdc.io/ncigdc/variant-filtration-tool:build-80-ead70e7d
  - class: InlineJavascriptRequirement

doc: Formats GDC SvABA Indel VCFs 

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
        position: 2

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: Updated VCF file

baseCommand: [format-svaba-vcf]
