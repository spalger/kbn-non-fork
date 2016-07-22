FROM kibana-ci/base

# Setup workspace
WORKDIR /repo
COPY [".", "."]
RUN chown kibana-ci -R /repo
USER kibana-ci
RUN /repo/ci/scripts/setup_repo.sh

# go!
COPY ci/scripts/run_tasks.sh /
ENTRYPOINT ["/run_tasks.sh"]
