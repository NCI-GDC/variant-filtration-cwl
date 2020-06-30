cwlVersion: v1.0
class: CommandLineTool
id: extract_oxoq_from_sqlite
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/variant-filtration-tool:6e5e350c1b9867b2271e209ece163f1c7b0eb4d1
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 1000
    tmpdirMin: 1
    outdirMin: 1
doc: |
    Extracts oxoq score from sqlite db 

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
      prefix: --input-state
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
baseCommand: [gdc-filtration-tools, extract-oxoq-from-sqlite]
