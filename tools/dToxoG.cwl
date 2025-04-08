cwlVersion: v1.0
class: CommandLineTool
id: dtoxog_tool
requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/broad-oxog-tool:{{ broad_oxog_tool }}" 
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: EnvVarRequirement
    envDef:
      - envName: LD_LIBRARY_PATH
        envValue: "/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/bin/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/sys/java/jre/glnxa64/jre/lib/amd64"
      - envName: XAPPLRESDIR
        envValue: "/usr/local/MATLAB/MATLAB_Compiler_Runtime/v717/X11/app-defaults"

doc: |
    Run dtoxog 

inputs:
  input_maf:
    type: File
    doc: Input MAF file to filter

  output_name:
    type: string
    doc: Name to use ad prefix in all output files

outputs:
  output_dir:
    type: Directory
    outputBinding:
      glob: $(inputs.output_name+'.dtoxog_results')

  log_file:
    type: File
    outputBinding:
      glob: $(inputs.output_name+'.dtoxog.logs')

baseCommand: [bash, -c]

arguments:
  - valueFrom: |
      ${
         var tool = "/cga/fh/pcawg_pipeline/modules/oxoG/oxoGFilter_v3/startFilterMAFFile";
         var cmd = ["Xvnc", ":$$", "-depth", "16&", "XVNC_PID=$!", "&&", "export", "DISPLAY=:$$",
                    "&&", tool, inputs.input_maf.path, inputs.output_name + '.oxog.maf',
                    './' + inputs.output_name + '.dtoxog_results', "0", "\'\'", 
                    "0.96", "0.01", "-1", "36", "1.5", ">", inputs.output_name + '.dtoxog.logs', 
                    "2>&1", "&&", "kill", "$XVNC_PID"];
         var shell_cmd = cmd.join(' ');
         return shell_cmd;
       }
    position: 0
