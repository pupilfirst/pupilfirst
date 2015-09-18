if Rails.env.production?
  DelayedJobWeb.use Rack::Auth::Basic do |username, password|
    username == ENV['DELAYED_JOB_WEB_USERNAME'] && password == ENV['DELAYED_JOB_WEB_PASSWORD']
  end
end
