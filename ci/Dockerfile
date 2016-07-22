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
COPY [".", "."]
RUN chown kibana-ci -R /repo
USER kibana-ci
RUN /repo/ci/scripts/setup_repo.sh

# go!
COPY ci/scripts/run_tasks.sh /
ENTRYPOINT ["/run_tasks.sh"]
