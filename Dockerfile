FROM ruby:2.7-slim

RUN apt update && apt install -y build-essential libpq-dev git imagemagick curl pdftk poppler-utils file
# Relax ImageMagick PDF security. See https://stackoverflow.com/a/59193253.
RUN sed -i '/rights="none" pattern="PDF"/d' /etc/ImageMagick-6/policy.xml
COPY config/clamd.conf /etc/clamav/clamd.conf

RUN mkdir /app
WORKDIR /app
COPY modules ./modules
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle install
COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
