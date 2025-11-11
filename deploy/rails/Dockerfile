FROM ruby:3.4.7-slim-trixie

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential libpq-dev libyaml-dev git

# Set working directory
WORKDIR /app

# Install bundler
RUN gem update --system 3.7.2
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY Gemfile  ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

EXPOSE 3000
EXPOSE 8080