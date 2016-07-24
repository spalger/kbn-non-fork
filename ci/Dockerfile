FROM kibanaci/base-n447-j8-chrome

# Setup workspace
RUN mkdir -p /repo
WORKDIR /repo

# validate the node version
COPY .node-version .
RUN \
  set -e; \
  n="$(node -v)"; \
  expected="v$(cat .node-version)"; \
  if [ "$n" != "$expected" ]; then \
    echo "incorrect node.js version ($n, expected $expected) installed. The Dockerfile needs updating"; \
    exit 1; \
  fi

# some grunt tasks require a git repo
RUN \
  set -e; \
  git init && \
  git config --global user.name "kibanaci" && \
  git config --global user.email kibanaci@ci-container && \
  git commit -q --allow-empty -m 'some grunt tasks need a repo'

# give ownership of the workspace to kibanaci user
RUN chown -R kibanaci /repo

# switch over to the kibanaci user
USER kibanaci

# copy just package.json so this step won't invalidate
# unless package.json is changed
COPY package.json .
RUN npm install

# copy the build context into the image
COPY [".", "."]

# give ownership of certain parts of the repo to kibanaci user
RUN \
  set -e; \
  sudo chown kibanaci .; \
  sudo chown -R kibanaci optimize node_modules;

# ensure that all dependencies are up to date, respecting semver, but reuse existing files
RUN npm --depth 9999 update
ENTRYPOINT ["./node_modules/.bin/babel-node", "ci/task_runner.js"]
