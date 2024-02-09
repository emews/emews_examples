import files;
import string;
import sys;
import io;
import python;
import location;
import unix;
import emews;
import stats;

import EQSQL;

// deletes the specified directory
app (void o) rm_dir(string dirname) {
  "rm" "-rf" dirname;
}

// deletes the specified directories
app (void o) rm_dirs(file dirnames[]) {
  "rm" "-rf" dirnames;
}

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
int resident_work_rank = string2int(getenv("RESIDENT_WORK_RANK"));

int TASK_TYPE = string2int(argv("task_type", "0"));
int BATCH_SIZE = string2int(argv("batch_size"));
int BATCH_THRESHOLD = string2int(argv("batch_threshold", "1"));
string WORKER_POOL_ID = argv("worker_pool_id", "default");

file model_sh = input(emews_root+"/scripts/run_my_model_eqsql_workflow.sh");
int n_trials = string2int(argv("trials", "1"));

printf("TASK_TYPE: %d", TASK_TYPE);
printf("BATCH_SIZE: %d", BATCH_SIZE);
printf("BATCH_THRESHOLD %d", BATCH_THRESHOLD);
printf("WORKER_ID: %s", WORKER_POOL_ID);
printf("TRIALS: %d", n_trials);


(float result) get_result(string output_file) {
    // TODO given the model output, set the the model result 
    file of = input(output_file);
    result = string2float(read(of));
}

(float agg_result) get_aggregate_result(float model_results[]) {
    // TODO replace with aggregate result calculation (e.g.,
    // take the average of model results with avg(model_results);
    agg_result = avg(model_results);
}


// app function used to run the task
app (file out, file err) run_task_app(file shfile, string task_payload, string output_file, int trial, string instance_dir) {
    "bash" shfile task_payload output_file trial emews_root instance_dir @stdout=out @stderr=err;
}

(float result) run_obj(string task_payload, int trial, string instance_dir, string instance_id) {
    file out <instance_dir + "/" + instance_id+"_out.txt">;
    file err <instance_dir + "/" + instance_id+"_err.txt">;
    string output_file = "%s/output_%s.csv" % (instance_dir, instance_id);
    (out,err) = run_task_app(model_sh, task_payload, output_file,  trial, instance_dir) =>
    result = get_result(output_file);
}

(string obj_result) run_task(int task_id, string task_payload) {
    float results[];

    string instance = "%s/instance_%i/" % (turbine_output, task_id);
    mkdir(instance) => {
        foreach i in [0:n_trials-1:1] {
            int trial = i + 1;
            string instance_id = "%i_%i" % (task_id, trial);
            results[i] = run_obj(task_payload, trial, instance, instance_id);
        }
    }

    obj_result = float2string(get_aggregate_result(results));
    printf("%d: %s", task_id, obj_result); // =>
    // TODO: delete the ";" above, uncomment the ""=>"" above and 
    // and the rm_dir below to delete the instance directory if
    // it is not needed after the result have been computed.
    // rm_dir(instance);
}


run(message msgs[]) {
  // printf("MSGS SIZE: %d", size(msgs));
  foreach msg, i in msgs {
    result_payload = run_task(msg.eq_task_id, msg.payload);
    eq_task_report(msg.eq_task_id, TASK_TYPE, result_payload);
  }
}


(void v) loop(location querier_loc) {
  for (boolean b = true;
       b;
       b=c)
  {
    message msgs[] = eq_batch_task_query(querier_loc);
    boolean c;
    if (msgs[0].msg_type == "status") {
      if (msgs[0].payload == "EQ_STOP") {
        printf("loop.swift: STOP") =>
          v = propagate() =>
          c = false;
      } else {
        // sleep to give time for Python etc.
        // to flush messages
        sleep(5);
        printf("loop.swift: got %s: exiting!", msgs[0].payload) =>
        v = propagate() =>
        c = false;
      }
    } else {
      run(msgs);
      c = true;
    }
  }
}

(void o) start() {
  location querier_loc = locationFromRank(resident_work_rank);
  eq_init_batch_querier(querier_loc, WORKER_POOL_ID, BATCH_SIZE, BATCH_THRESHOLD, TASK_TYPE) =>
  loop(querier_loc) => {
    eq_stop_batch_querier(querier_loc);
    o = propagate();
  }
}

start() => printf("worker pool: normal exit.");