import argparse
import yaml
import json
import random
from typing import Dict

from eqsql import eq, worker_pool, db_tools


def run(exp_id: str, params: Dict):
    db_started = False
    pool = None
    task_queue = None
    try:
        # start database
        db_tools.start_db(params['db_path'])
        db_started = True

        # start worker pool
        pool_params = worker_pool.cfg_file_to_dict(params['pool_cfg_file'])
        pool = worker_pool.start_local_pool(params['worker_pool_id'], params['pool_launch_script'],
                                            exp_id, pool_params)
        # start task queue
        task_queue = eq.init_task_queue(params['db_host'], params['db_user'],
                                        port=None, db_name=params['db_name'])
        task_type = params['task_type']
        fts = []
        for _ in range(10):
            payload = {'x': random.uniform(0, 10), 'y': random.uniform(0, 10)}
            _, ft = task_queue.submit_task(exp_id, task_type, json.dumps(payload))
            fts.append(ft)

        for ft in eq.as_completed(fts):
            print(ft.result())

    finally:
        if task_queue is not None:
            task_queue.close()
        if pool is not None:
            pool.cancel()
        if db_started:
            db_tools.stop_db(params['db_path'])


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('exp_id', help='experiment id')
    parser.add_argument('config_file', help="yaml format configuration file")
    return parser


if __name__ == '__main__':
    parser = create_parser()
    args = parser.parse_args()
    with open(args.config_file) as fin:
        params = yaml.safe_load(fin)

    run(args.exp_id, params)
