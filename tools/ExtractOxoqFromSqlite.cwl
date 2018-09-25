#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    Extracts oxoq score from sqlite db 

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:920c0615f6df7c4bbb7adc1f0e82606bd53e5277 
  - class: InlineJavascriptRequirement

inputs:
  context:
    type: string?
    default: "CCG"
    inputBinding:
      prefix: --context
      position: 0

  table:
    type: string?
    default: "picard_CollectOxoGMetrics"
    inputBinding:
      prefix: --table
      position: 1

  input_state:
    type: string?
    default: "markduplicates_readgroups"
    inputBinding:
      prefix: --input_state
      position: 2

  db_file:
    type: File
    doc: Absolute filename of input SQLite db
    inputBinding:
      position: 3

outputs:
  oxoq_score:
    type: float
    outputBinding:
      loadContents: true
      glob: "oxoq.txt" 
      outputEval: |
        ${
           return parseFloat(self[0].contents); 
         }

stdout: "oxoq.txt"
baseCommand: [python3, /variant-filtration-tool/ExtractOxoqFromSqlite.py]
