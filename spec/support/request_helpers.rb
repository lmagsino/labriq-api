module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def login_as(user)
    post "/api/v1/auth/login", params: { user: { email: user.email, password: user.password } }, as: :json
    response.headers['Authorization']
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
