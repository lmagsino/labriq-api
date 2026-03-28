class RateLimiter
  SCAN_LIMIT = 5
  WINDOW_SECONDS = 3600

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)

    if request.path == "/api/v1/scans" && request.post?
      ip = request.remote_ip
      key = "rate_limit:scans:#{ip}"

      redis = Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
      count = redis.get(key).to_i

      if count >= SCAN_LIMIT
        return [
          429,
          { "Content-Type" => "application/json" },
          ['{"error":"Rate limit exceeded. Max 5 scans per hour."}']
        ]
      end

      redis.multi do |r|
        r.incr(key)
        r.expire(key, WINDOW_SECONDS)
      end
    end

    @app.call(env)
  end
end
