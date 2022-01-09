cwlVersion: v1.0
class: CommandLineTool
id: picard_vcf_format_converter
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/picard:2.26.10
  - class: InlineJavascriptRequirement
    expressionLib:
      $import: ./util_lib.cwl
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 5000
    tmpdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))
    outdirMin: $(file_size_multiplier(inputs.input_vcf, 1.2))

doc: Converts a VCF using picard.

inputs:
  input_vcf:
    type: File
    doc: "input vcf file"
    inputBinding:
      prefix: "INPUT="
      separate: false

  output_filename:
    type: string
    doc: output basename of output file
    inputBinding:
      prefix: "OUTPUT="
      separate: false

  create_index:
    type: string
    default: "true"
    inputBinding:
      prefix: "CREATE_INDEX="
      separate: false

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles: |
      ${
         if(inputs.output_filename.indexOf('.gz') == -1) {
           return({"class": "File", "location": self.location + '.idx'});
         } else {
           return({"class": "File", "location": self.location + '.tbi'});
         }
       }
    doc: Formatted VCF file

baseCommand: [java, -Xmx4G, -jar, /usr/local/bin/picard.jar, VcfFormatConverter, REQUIRE_INDEX=false]
