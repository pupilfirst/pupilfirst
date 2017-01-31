namespace :lita do
  desc 'Handle vocalist notifications and responses on Public Slack.'
  task vocalist: [:environment] do
    # Require lita, and adapter.
    require 'lita'
    require 'lita-slack'

    # Require all handlers.
    require_rel '../lita/handlers/*'

    lita_config_path = File.expand_path(File.join(Rails.root, 'config', 'lita_config.rb'))
    Lita.run(lita_config_path)
  end
end
