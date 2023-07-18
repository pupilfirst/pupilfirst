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
            File.read(Rails.root.join("public", "maintenance.html.erb"))
          ).result
        ]
      ]
    else
      @app.call(env)
    end
  end
end
