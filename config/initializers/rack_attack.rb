# Safelist requests from signed in users in the web app
Rack::Attack.safelist(
  'mark authenticated request from web app users as safe'
) do |request|
  request.env['HTTP_COOKIE'].present? &&
    request.env['HTTP_AUTHORIZATION'].blank?
end

# Safelist GET requests
Rack::Attack.safelist('mark get requests as safe') { |request| request.get? }

# Throttle GraphQL API requests to a configurable value per second that defaults to 20 requests/second
Rack::Attack.throttle(
  'limits GraphQL api requests using API token',
  limit: ENV['GRAPH_API_RATE_LIMIT']&.to_i || 300,
  period: ENV['GRAPH_API_RATE_PERIOD']&.to_i || 60
) do |request|
  header = request.env['HTTP_AUTHORIZATION']&.strip
  api_token = header.split(' ')[-1] if header.present?
  if request.path == '/graphql' && request.post? && api_token.present?
    Digest::SHA2.base64digest(api_token)
  end
end
