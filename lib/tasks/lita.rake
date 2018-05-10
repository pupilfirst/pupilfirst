namespace :lita do
  desc 'Handle vocalist notifications and responses on Public Slack.'
  task vocalist: [:environment] do
    # Require lita, and adapter.
    require 'lita'
    require 'lita-slack'

    # Require all handlers.
    require_relative '../lita/handlers/backup'
    require_relative '../lita/handlers/changelog'
    require_relative '../lita/handlers/leaderboard'
    require_relative '../lita/handlers/targets'
    require_relative '../lita/handlers/thanks'

    lita_config_path = File.expand_path(Rails.root.join('config', 'lita_config.rb'))
    Lita.run(lita_config_path)
  end
end
