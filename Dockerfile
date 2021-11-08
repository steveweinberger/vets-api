# Built with Docker's multi-stage builds feature. To just build the development
# stage, run `docker build --tag vets-api --target development .` To build the
# full file, run `docker build --tag vets-api .`.

FROM ruby:2.7-slim

# Allow for setting ENV vars via --build-arg
ARG BUNDLE_ENTERPRISE__CONTRIBSYS__COM
ARG RAILS_ENV=development
ENV RAILS_ENV=$RAILS_ENV
ENV BUNDLE_ENTERPRISE__CONTRIBSYS__COM=$BUNDLE_ENTERPRISE__CONTRIBSYS__COM

WORKDIR /app

RUN apt-get update && \
  apt-get install -y build-essential libpq-dev git imagemagick curl wget pdftk poppler-utils file vim

# Relax ImageMagick PDF security. See https://stackoverflow.com/a/59193253.
RUN sed -i '/rights="none" pattern="PDF"/d' /etc/ImageMagick-6/policy.xml

COPY config/clamd.conf /etc/clamav/clamd.conf

# Download VA Certs
RUN wget -q -r -np -nH -nd -a .cer -P /usr/local/share/ca-certificates http://aia.pki.va.gov/PKI/AIA/VA/ && \
  for f in /usr/local/share/ca-certificates/*.cer; do openssl x509 -inform der -in $f -out $f.crt; done && \
  update-ca-certificates

RUN gem install bundler --no-document
RUN bundle config --global jobs 4

COPY modules /app/modules
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
RUN rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete \
  && find /usr/local/bundle/gems/ -name ".git"  -type d -prune -execdir rm -rf {} +
COPY . .


EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
