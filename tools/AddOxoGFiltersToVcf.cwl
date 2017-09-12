#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    Annotates VCF with D-ToxoG results 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:0.4
  - class: InlineJavascriptRequirement

inputs:
  input_vcf:
    type: File
    doc: Absolute filename of input full SNV VCF file 
    inputBinding:
      position: 0 

  input_dtoxog:
    type: File
    doc: Absolute filename of annotated minimal VCF from DToxoG 
    inputBinding:
      position: 1 
    secondaryFiles:
      - ".tbi"

  output_filename:
    type: string
    doc: filename of output vcf file (should end with .gz)
    inputBinding:
      position: 2 

outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
    doc: The tabix indexed output file
    secondaryFiles:
        - ".tbi" 

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/gdc-biasfilter-tool/AddOxoGFiltersToVcf.py]
