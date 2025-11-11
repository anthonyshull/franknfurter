FROM ruby:3.4.7-slim-trixie

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential git libpq-dev libyaml-dev

# Set working directory
WORKDIR /app

# Install bundler
RUN gem update --system 3.7.2
RUN gem install bundler

# Copy Gemfile and Gemfile.lock
COPY Gemfile  ./
COPY Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application
COPY . .

# Copy and set up entrypoint
COPY deploy/rails/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
EXPOSE 8080