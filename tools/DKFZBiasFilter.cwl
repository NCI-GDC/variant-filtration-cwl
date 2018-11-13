#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "DKFZ Bias Filter"
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/dkfz-biasfilter:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_vcf)
      - $(inputs.input_bam)
      - $(inputs.input_bam_index)
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)
  - $import: schemas.cwl

inputs:
  write_qc:
    type: boolean
    default: true
    doc: "Write quality control? If true, then a folder is created within the same folder as the filtered vcf file storing bias plots and qc files"
    inputBinding:
      position: 0
      prefix: -q

  min_mapq:
    type: int?
    default: 1
    doc: Minimal mapping quality of a read to be considered for error count calculation
    inputBinding:
      position: 1
      prefix: --mapq=
      separate: false

  min_baseq:
    type: int?
    default: 1
    doc: Minimal base quality to be considered for error count calculation
    inputBinding:
      position: 2
      prefix: --baseq=
      separate: false

  input_vcf:
    type: File
    doc: "Absolute filename of input vcf file"
    inputBinding:
      position: 3
      valueFrom: $(self.basename)

  input_bam:
    type: File
    doc: "Absolute filename of tumor bam file"
    inputBinding:
      position: 4
      valueFrom: $(self.basename)

  input_bam_index:
    type: File
    doc: "Absolute filename of tumor bam file index"

  reference_sequence:
    type: File
    doc: "Absolute filename of reference sequence file"
    inputBinding:
      position: 5
      valueFrom: $(self.basename)

  reference_sequence_index:
    type: File
    doc: "Absolute filename of reference sequence file index"

  uuid:
    type: string
    doc: UUID used for prefix of output files

outputs:
  output_vcf_file:
    type: File
    outputBinding:
      glob: $(inputs.uuid + '.dkfz.vcf')
    doc: "The filtered vcf file"

  output_qc_folder:
    type: Directory?
    outputBinding:
      glob: $(inputs.uuid + '.dkfz_qcSummary')
    doc: "The qc folder"

  time_record:
    type: "schemas.cwl#time_record"
    outputBinding:
      loadContents: true
      glob: $(inputs.uuid + '.dkfz.time.json')
      outputEval: |
        ${
           var data = JSON.parse(self[0].contents);
           return data;
         }

baseCommand: [/usr/bin/time]

arguments:
  - valueFrom: "{\"real_time\": \"%E\", \"user_time\": %U, \"system_time\": %S, \"wall_clock\": %e, \"maximum_resident_set_size\": %M, \"percent_of_cpu\": \"%P\"}"
    position: -10
    prefix: -f
  - valueFrom: $(inputs.uuid + '.dkfz.time.json')
    prefix: -o
    position: -9
  - valueFrom: python
    position: -8
  - valueFrom: /usr/local/bin/biasFilter.py
    position: -7
  - valueFrom: --tempFolder=/var/spool/cwl/
    position: -6
  - valueFrom: $('/var/spool/cwl/' + inputs.uuid + '.dkfz.vcf')
    position: 6
