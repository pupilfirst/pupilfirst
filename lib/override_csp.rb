class OverrideCsp
  ALLOW_EVERYTHING = "default_src: *"

  def initialize(app, csp = ALLOW_EVERYTHING)
    @app = app
    @csp = csp
  end

  def call(env)
    status, headers, body = @app.call(env)
    [status, headers.merge('Content-Security-Policy' => @csp), body]
  end
end