#!/usr/bin/env cwl-runner

class: CommandLineTool

cwlVersion: v1.0
doc: |
    A Docker container for the PCAWG OXOG metrics tool.

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/broad-oxog-tool 
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_bam)
      - $(inputs.input_bam_index)
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)
      - $(inputs.reference_sequence_dictionary)

inputs:
  input_bam:
    type: File
    doc: Absolute filename of tumor bam file
    inputBinding:
      prefix: -I
      valueFrom: $(self.basename)

  input_bam_index:
    type: File
    doc: Absolute filename of tumor bam file index

  reference_sequence:
    type: File
    doc: Absolute filename of reference sequence file
    inputBinding:
      prefix: -R
      valueFrom: $(self.basename)

  reference_sequence_index:
    type: File
    doc: Absolute filename of reference sequence file index

  reference_sequence_dictionary:
    type: File
    doc: Absolute filename of reference sequence file dictionary

  intervals:
    type: File
    doc: interval file
    inputBinding:
      prefix: -L

  output_filename:
    type: string
    doc: filename of output metrics file
    inputBinding:
      prefix: -o

outputs:
  output_metrics_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    doc: The OXOQ metrics file

baseCommand: [java, -Xmx4G, -jar, /cga/fh/pcawg_pipeline/modules/oxoG/oxoGMetrics/GenomeAnalysisTK.jar, --analysis_type, OxoGMetrics]
