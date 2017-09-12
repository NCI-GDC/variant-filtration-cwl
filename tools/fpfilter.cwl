#!/usr/bin/env cwl-runner

class: CommandLineTool
label: "fpfilter"
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/fpfilter:latest
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.input_bam)
      - $(inputs.input_bam_index)
      - $(inputs.reference_sequence)
      - $(inputs.reference_sequence_index)
  - $import: schemas.cwl

inputs:
  vcf_file:
    type: File
    doc: path to VCF file you wish to filter
    inputBinding:
      prefix: --vcf-file

  input_bam:
    type: File
    doc: path to BAM file of tumor
    inputBinding:
      prefix: --bam-file 
      valueFrom: $(self.basename)

  input_bam_index:
    type: File
    doc: path to BAI file of tumor
    inputBinding:
      prefix: --bam-index
      valueFrom: $(self.basename)

  sample:
    type: string
    doc: "the sample name of the sample you want to filter on in the VCF file"
    inputBinding:
        prefix: --sample

  reference_sequence:
    type: File
    doc: "a fasta containing the reference sequence the BAM file was aligned to"
    inputBinding:
      prefix: --reference
      valueFrom: $(self.basename)

  reference_sequence_index:
    type: File
    doc: fasta fai index file 

  output_filename:
    type: string
    doc: "the filename of the output VCF file"
    inputBinding:
      prefix: --output

  min_read_pos:
    type: float?
    label: "Min read position"
    doc: "minimum average relative distance from start/end of read [0.10]"
    inputBinding:
      prefix: --min-read-pos

  min_var_freq:
    type: float?
    label: "Min variant frequency"
    doc: "minimum variant allele frequency [0.05]"
    inputBinding:
      prefix: --min-var-freq

  min_var_count:
    type: int?
    label: "Min variant count"
    doc: "minimum number of variant-supporting reads [4]"
    inputBinding:
      prefix: --min-var-count

  min_strandedness:
    type: float?
    label: "Min strandedness"
    doc: "minimum representation of variant allele on each strand [0.01]"
    inputBinding:
      prefix: --min-strandedness

  max_mm_qualsum_diff:
    type: int?
    label: "Max qualsum diff"
    doc: "maximum difference of mismatch quality sum between variant and reference reads (paralog filter) [50]"
    inputBinding:
      prefix: --max-mm-qualsum-diff

  max_var_mm_qualsum:
    type: int?
    label: "Max var qualsum"
    doc: "maximum mismatch quality sum of reference-supporting reads [100]"
    inputBinding:
      prefix: --max_var_mm_qualsum

  max_mapqual_diff:
    type: int?
    label: "Max mapqual diff"
    doc: "maximum difference of mapping quality between variant and reference reads [30]"
    inputBinding:
      prefix: --max-mapqual-diff

  max_readlen_diff:
    type: int?
    label: "Max read length diff"
    doc: "maximum difference of average supporting read length between variant and reference reads (paralog filter) [25]"
    inputBinding:
      prefix: --max-readlen-diff

  min_var_dist_3:
    type: float?
    label: "Min ave distance"
    doc: "minimum average distance to effective 3prime end of read (real end or Q2) for variant-supporting reads [0.20]"
    inputBinding:
      prefix: --min-var-dist-3

outputs:
  vcf_out:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

  time_record:
    type: "schemas.cwl#time_record"
    outputBinding:
      loadContents: true
      glob: $(inputs.output_filename + '.fpfilter.time.json')
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
  - valueFrom: $(inputs.output_filename + '.fpfilter.time.json')
    prefix: -o
    position: -9
  - valueFrom: /usr/bin/perl
    position: -8
  - valueFrom: /opt/fpfilter.pl
    position: -7
