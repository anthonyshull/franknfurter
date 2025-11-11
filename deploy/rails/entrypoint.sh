#!/bin/bash
set -e

# Install any missing gems (in case Gemfile changed)
bundle check || bundle install

# Execute the main command
exec "$@"
