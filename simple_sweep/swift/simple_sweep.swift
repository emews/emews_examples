import io;
import sys;
import files;
import string;
import emews;
import python;
import stats;
import R;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string lang = argv("lang", "py");
file upf = input(argv("f"));

string code = """
x = %s * 2
""";


// call this to create any required directories
app (void o) make_dir(string dirname) {
    "mkdir" "-p" dirname;
}


// Iterate over each line in the upf file, passing each line 
// to the model script to run
main() {
    string upf_lines[] = file_lines(upf);
    int results[];
    if (lang == "py") {
        foreach s, i in upf_lines {
            string py_code = code % s;
            string result = python_persist(py_code, "str(x)");
            results[i] = string2int(result);
        }
    } else {
        foreach s, i in upf_lines {
            string r_code = code % s;
            string result = R(r_code, "toString(x)");
            results[i] = string2int(result);
        }
    }
    
    printf("Sum: %d", sum_integer(results));
        // string instance = "%s/instance_%i/" % (turbine_output, i+1);
        // make_dir(instance) => {
        //     file out <instance+"out.txt">;
        //     file err <instance+"err.txt">;
        //     (out,err) = run_model(model_sh, s, instance);
        // }
}
    

