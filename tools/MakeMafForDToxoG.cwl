#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    Convert a SNP VCF to the input MAF format required for DToxoG 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gdc-biasfilter-tool:0.4
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)

inputs:
  gatk_oxog_file: 
    type: File
    doc: metrics file from the GATK oxoG metrics tool 
    inputBinding:
      prefix: --oxog_file 

  oxoq_score: 
    type: float 
    doc: extracted OXOQ score 
    inputBinding:
      prefix: --oxoq_score

  input_vcf: 
    type: File
    doc: input SNP VCF file 
    inputBinding:
      prefix: --input_vcf

  reference_sequence: 
    type: File
    doc: Reference fasta file 
    inputBinding:
      prefix: --reference 
      valueFrom: $(self.basename)

  reference_sequence_index: 
    type: File
    doc: Reference faidx file 

  output_filename:
    type: string
    doc: filename of output maf file
    inputBinding:
      prefix: --output_maf 

outputs:
  output_maf_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename) 
    doc: The MAF file 

baseCommand: [/home/ubuntu/.virtualenvs/p2/bin/python, /home/ubuntu/tools/gdc-biasfilter-tool/MakeMafForDToxoG.py]
