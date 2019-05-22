#FROM fluentd:latest
#FROM fluentd:v1.5.0-debian-1.0
FROM ruby:2.5

#USER root
#RUN apt-get update && apt-get install -y ruby-dev 
#RUN apk add --no-cache --update --virtual .build-deps \
#        sudo build-base ruby-dev zlib-dev
#RUN gem install fluentd-ui --no-ri --no-rdoc

RUN gem install fluentd && \
    fluent-gem install fluentd-ui && \
    fluent-gem install minitest && \
    fluent-gem install rake
RUN fluentd-ui setup

#COPY fluentd.conf /etc/fluentd/

#USER fluent

CMD ["fluentd-ui", "start"]
