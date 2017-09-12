#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    Extracts results from DToxoG MAF into a minimal tabix indexed VCF 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:0.4
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.reference_fasta)
      - $(inputs.reference_index)

inputs:
  input_maf:
    type: File
    doc: Absolute filename of input full MAF annotated file from dtoxog 
    inputBinding:
      position: 0 

  reference_fasta:
    type: File
    doc: the reference fasta file
    inputBinding:
      position: 1
      valueFrom: $(self.basename)

  reference_index:
    type: File
    doc: the faidx file

  output_filename:
    type: string
    doc: filename of output vcf file (must end with .gz extension)
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

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/gdc-biasfilter-tool/ProcessDToxoG.py]
