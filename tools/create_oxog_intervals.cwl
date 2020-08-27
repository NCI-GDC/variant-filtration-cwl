class: CommandLineTool
cwlVersion: v1.0
id: create_oxog_intervals
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:1.0.2 
  - class: InlineJavascriptRequirement

doc: |
  Takes a SNP-only VCF file and creates an interval list for
  use by the Broad oxog metrics tool.

inputs:
  input_vcf:
    type: File
    doc: Absolute filename of input SNP vcf file
    inputBinding:
      position: 0

  output_filename:
    type: string
    doc: filename of output interval file
    inputBinding:
      position: 1

outputs:
  output_interval_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: The interval list file

baseCommand: [create-oxog-intervals]
