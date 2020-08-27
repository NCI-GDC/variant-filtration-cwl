cwlVersion: v1.0
class: ExpressionTool
id: make_file_prefix
requirements:
  - class: InlineJavascriptRequirement

inputs:
  project_id:
    type: string?

  caller_id:
    type: string?

  job_id:
    type: string

  experimental_strategy:
    type: string

outputs:
  output:
    type: string

expression: |
  ${
     var exp = inputs.experimental_strategy.toLowerCase().replace(/[-\s]/g, "_");

     var pid = inputs.project_id ? inputs.project_id + '.': '';
     var cid = inputs.caller_id ? '.' + inputs.caller_id.replace(/[-\s]/g, "_") : '';
     var pfx = pid + inputs.job_id + '.' + exp + cid; 

     return {'output': pfx};
   }
