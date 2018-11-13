#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "Picard VcfFormatConverter"
cwlVersion: v1.0
doc: |
    Converts a VCF.

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:3839a594cab6b8576e76124061cf222fb3719f20
  - class: InlineJavascriptRequirement

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

baseCommand: [java, -Xmx4G, -jar, /opt/picard.jar, VcfFormatConverter, REQUIRE_INDEX=false]
