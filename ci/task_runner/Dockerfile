FROM kibana-ci/base:master

# Setup workspace
WORKDIR /repo

# validate the env, make sure node is correct version and stuff like that
COPY .node-version ./
COPY ci/task_runner/validate_env.sh /
RUN /validate_env.sh

USER kibana-ci

# copy just package.json so this step won't invalidate
# unless package.json is changed
COPY package.json .
RUN npm install

# copy the whole project and setup
COPY [".", "."]
RUN ci/task_runner/setup_repo.sh

# go!
ENTRYPOINT ["ci/task_runner/run_tasks.sh"]
