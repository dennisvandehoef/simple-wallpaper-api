require "resque"

Resque.redis = ENV.fetch("REDIS_URL", "redis://redis:6379/0")

# If using ActiveJob (Rails default), ensure that Resque is the adapter.
Rails.application.config.active_job.queue_adapter = :resque
