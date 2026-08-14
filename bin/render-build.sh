#!/usr/bin/env bash
set -o errexit

bundle install
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails db:seed
RAILS_ENV=production bundle exec rails assets:precompile
