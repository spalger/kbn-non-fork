import { readdirSync } from 'fs';
import { basename, resolve } from 'path';
import program from 'commander';
import { spawn } from 'child_process';
import { red, green, blue } from 'ansicolors';

const TASK_DIR = resolve(__dirname, './tasks');
const TASK_NAMES = readdirSync(TASK_DIR)
  .filter(n => n.endsWith('.sh'))
  .map(n => basename(n, '.sh'));

program
  .usage('[options] <task ...>')
  .option('--tasks')
  .parse(process.argv);

const log = {
  info(...log) {
    console.log(blue('ℹ︎'), ...log);
  },
  fail(...log) {
    console.log(red('𝘅'), ...log);
    process.exit(1);
  },
  success(...log) {
    console.log(green('✔'), ...log);
  }
};

Promise.resolve()
  .then(main)
  .catch(err => log.fail('UNCAUGHT ERROR', err));

async function main() {
  try {
    if (program.tasks) {
      TASK_NAMES.map(n => console.log(n));
      return;
    }

    const { success } = log;
    const taskArgs = getTaskArgs(program);
    const taskQueue = getTaskQueue(taskArgs);
    await processTaskQueue(taskQueue);
    success('All tasks complete');
  } catch (err) {
    console.log(red('FATAL ERROR:'), err.stack);
    process.exit(10);
  }
}

function getTaskArgs(program) {
  if (program.args.length) {
    return program.args;
  }

  log.fail(
    'You must specify at least one task, options:',
    ...TASK_NAMES.map(n => `\n - ${n}`)
  );
}

function getTaskQueue(taskArgs) {
  const { info, fail } = log;

  const unknown = [];
  const queue = taskArgs.map(taskArg => {
    // taskArg passed into the scripts can be a path to the
    // task file, or taskname.sh or just taskname so we
    // trim it down to just the filename
    const task = basename(taskArg, '.sh');

    if (!TASK_NAMES.includes(task)) {
      unknown.push(taskArg);
      return;
    }

    return task;
  });

  if (unknown.length) {
    fail(`Unknown task${unknown.length > 1 ? 's' : ''} "${unknown.join('", "')}"`);
  }

  return queue;
}

class TaskFailure extends Error {}

const liveProcs = new Set;
process.on('exit', () => {
  for (const proc of liveProcs) proc.kill();
});

async function processTaskQueue(queue) {
  /* eslint-disable no-loop-func */
  while (queue.length) {
    const task = resolve(TASK_DIR, `${queue.shift()}.sh`);
    const cleanup = new Set;

    log.info('starting', task);
    const proc = spawn(task, [], { stdio: 'inherit' });

    liveProcs.add(proc);
    cleanup.add(() => liveProcs.delete(proc));

    try {
      await new Promise((resolve, reject) => {
        proc.on('exit', code => {
          if (code > 0) {
            reject(new TaskFailure(`task exitted with status ${code}`));
          } else {
            resolve();
          }
        });
      });
    } finally {
      for (const clean of cleanup) clean();
    }
  }
}
