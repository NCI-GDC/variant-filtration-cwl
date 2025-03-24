class: CommandLineTool
cwlVersion: v1.0
id: dkfz_bias_filter
requirements:
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/dkfz-biasfilter:{{ dkfz-biasfilter }}"
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_vcf)
      - $(inputs.input_bam)
      - $(inputs.input_bam_index)
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)

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

baseCommand: [python, /usr/local/bin/biasFilter.py]

arguments:
  - valueFrom: |
      ${
        return '--tempFolder=' + runtime.outdir + '/';
      }
    position: 0
  - valueFrom: |
      ${
        return runtime.outdir + '/' + inputs.uuid + '.dkfz.vcf'
      }
    position: 6