FROM buildpack-deps:xenial

# System
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
COPY ci/base/setup_system.sh /
RUN /setup_system.sh

# Node.js
ENV NODE_VERSION 4.4.7
COPY ci/base/setup_node.sh /
RUN /setup_node.sh

# Java
ENV JAVA_VERSION 8
COPY ci/base/setup_java.sh /
RUN /setup_java.sh
ENV JAVA_HOME /JAVA_HOME

# Browser
ENV DBUS_SESSION_BUS_ADDRESS /dev/null
COPY ci/base/setup_browser.sh /
RUN /setup_browser.sh
COPY ci/base/chrome_launcher.sh /opt/google/chrome/google-chrome
