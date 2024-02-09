import sys
import json


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
