class Maintenance
  def initialize(app)
    @app = app
  end

  def call(env)
    if Rails.application.secrets.maintenance_mode
      [
        503,
        { "Content-Type" => "text/html" },
        [
          ERB.new(
            Rails.public_path.join("maintenance.html.erb").read
          ).result
        ]
      ]
    else
      @app.call(env)
    end
  end
end
