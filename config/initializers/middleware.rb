require Rails.root.join("app/middleware/rate_limiter")
Rails.application.config.middleware.use RateLimiter
