import sys
import json

# printf("TASK_TYPE: %d", TASK_TYPE);
# printf("BATCH_SIZE: %d", BATCH_SIZE);
# printf("BATCH_THRESHOLD %d", BATCH_THRESHOLD);
# printf("WORKER_ID: %s", WORKER_POOL_ID);
# printf("TRIALS: %d", n_trials);


# (float result) get_result(string output_file) {
#     // TODO given the model output, set the the model result 
#     file of = input(output_file);
#     result = string2float(read(of));
# }

# (float agg_result) get_aggregate_result(float model_results[]) {
#     // TODO replace with aggregate result calculation (e.g.,
#     // take the average of model results with avg(model_results);
#     agg_result = avg(model_results);
# }

# MODEL_CMD="python3"
# # TODO: Define the arguments to the MODEL_CMD. Each argument should be
# # surrounded by quotes and separated by spaces. For example,
# # arg_array=("$EMEWS_ROOT/python/my_model.py" "$PARAM_LINE" "$OUTPUT_FILE" "$TRIAL_ID")
# arg_array=("$EMEWS_ROOT/python/obj.py"
#            "$PARAM_LINE"
#            "$OUTPUT_FILE"
#            "$TRIAL_ID")


def run(param_line, output_file, trial):
    params = json.loads(param_line)
    x = params['x']
    y = params['y']
    result = x * y + trial
    with open(output_file, 'w') as fout:
        fout.write(f'{result}\n')


if __name__ == '__main__':
    param_line = sys.argv[1]
    output_file = sys.argv[2]
    trial = int(sys.argv[3])
    run(param_line, output_file, trial)
