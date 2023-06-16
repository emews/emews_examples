library(reticulate)
library(jsonlite)
library(EQ.SQL)
library(yaml)


run <- function(exp_id, params) {
    db_started <- FALSE
    pool <- NULL
    task_queue <- NULL

    eqsql <- init_eqsql(python_path = params$python_path)

    tryCatch({
        eqsql$db_tools$start_db(params$db_path)
        db_started <- TRUE

        pool_params <- eqsql$worker_pool$cfg_file_to_dict(params$pool_cfg_file)
        pool <- eqsql$worker_pool$start_local_pool(params$worker_pool_id, params$pool_launch_script,
                                                   exp_id, pool_params)

        task_queue <- init_task_queue(eqsql, params$db_host, params$db_user, params$db_port,
                                      params$db_name)
        task_type <- params$task_type
        m <- matrix(runif(20), nrow=10)
        fts <- apply(m, 1, function(x) {
            payload_lst <- list(x = x[1], y = x[2])
            payload <- toJSON(payload_lst, auto_unbox = TRUE)
            submission <- task_queue$submit_task(exp_id, task_type, payload)
            # return the future task
            submission[[2]]
        })

        results <- as_completed(eqsql, fts, function(ft) {
            fromJSON(ft$result()[[2]])
        })

        results

    }, finally = {
        if (!is.null(task_queue)) task_queue$close()
        if (!is.null(pool)) pool$cancel()
        if (db_started) eqsql$db_tools$stop_db(params$db_path)
    })
}

args <- commandArgs(trailingOnly = TRUE)
exp_id <- args[1]
params_file <- args[2]
params <- yaml.load_file(params_file)
run(exp_id, params)
