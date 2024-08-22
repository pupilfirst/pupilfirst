class Maintenance
  def initialize(app)
    @app = app
  end

  def call(env)
    if Settings.maintenance_mode
      [
        200,
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
