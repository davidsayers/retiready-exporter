FROM ruby:3.3.2-alpine3.20

RUN apk update \
 && apk add --no-cache  \
    build-base  \
    ruby-dev

COPY ./ /

RUN bundle

EXPOSE 9292

ENTRYPOINT ["rackup", "-o", "0.0.0.0"]
