FROM buildpack-deps:xenial

# System
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
COPY ci/scripts/setup_system.sh /
RUN /setup_system.sh

# Node.js
ENV NODE_VERSION 4.4.7
COPY ci/scripts/setup_node.sh /
RUN /setup_node.sh

# Java
ENV JAVA_VERSION 8
COPY ci/scripts/setup_java.sh /
RUN /setup_java.sh
ENV JAVA_HOME /JAVA_HOME

# Browser
ENV DBUS_SESSION_BUS_ADDRESS /dev/null
COPY ci/scripts/setup_browser.sh /
RUN /setup_browser.sh
COPY ci/scripts/chrome_launcher.sh /opt/google/chrome/google-chrome

# Setup workspace
WORKDIR /repo

# validate the env, make sure node is correct version and stuff like that
COPY .node-version ./
COPY ci/scripts/validate_env.sh /
RUN /validate_env.sh

USER kibana-ci

# copy just package.json so this step won't invalidate
# unless package.json is changed
COPY package.json .
RUN npm install

# copy the whole project and setup
COPY [".", "."]
RUN ci/scripts/setup_repo.sh

# go!
ENTRYPOINT ["ci/scripts/run_tasks.sh"]
