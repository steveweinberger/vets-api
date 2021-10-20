FROM ruby:2.7-slim

RUN apt-get update && \
  apt-get install -y build-essential libpq-dev git imagemagick curl wget pdftk poppler-utils file
# Relax ImageMagick PDF security. See https://stackoverflow.com/a/59193253.
RUN sed -i '/rights="none" pattern="PDF"/d' /etc/ImageMagick-6/policy.xml
COPY config/clamd.conf /etc/clamav/clamd.conf

# Download VA Certs
RUN wget -q -r -np -nH -nd -a .cer -P /usr/local/share/ca-certificates http://aia.pki.va.gov/PKI/AIA/VA/ && \
  for f in /usr/local/share/ca-certificates/*.cer; do openssl x509 -inform der -in $f -out $f.crt; done && \
  update-ca-certificates

RUN mkdir /app
WORKDIR /app
COPY modules ./modules
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
