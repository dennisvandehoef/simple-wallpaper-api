# syntax=docker/dockerfile:1

# Simple single-stage image for development / runtime
# Build: docker build -t simple_wallpaper_api .
# Run  : docker run -it --rm -p 3000:3000 -e RAILS_MASTER_KEY=... -e SECRET_KEY_BASE=... simple_wallpaper_api

ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

WORKDIR /rails

# Install system dependencies required by Rails and common gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libyaml-dev pkg-config \
    curl libjemalloc2 libvips sqlite3 imagemagick \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install gems first (leverages Docker layer cache)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

# Copy the application code
COPY . .

# Default command – start the Rails server in development mode
EXPOSE 3000
CMD ["bash", "-c", "bundle exec rails server -b 0.0.0.0 -p 3000"]
