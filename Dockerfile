FROM ubuntu:14.04
MAINTAINER Lars Gierth <larsg@systemli.org>

RUN apt-get update
RUN apt-get install -y python-virtualenv python-dev
RUN mkdir /venv /buildbot \
  && virtualenv /venv \
  && . venv/bin/activate \
  && pip install buildbot==0.8.12 \
  && apt-get clean -y
ADD ./entrypoint.sh /entrypoint.sh

VOLUME [ "/buildbot" ]
EXPOSE 8010

ENTRYPOINT [ "/entrypoint.sh" ]
