namespace :lita do
  desc 'Send out e-mails and push notifications for startup agreements that are about to expire.'
  task vocalist: [:environment] do
    # Require lita, and adapter.
    require 'lita'
    require_rel '../../../lita-slack/lita-slack/lib/lita-slack'

    # Require all handlers.
    require_rel '../lita/handlers/*'

    lita_config_path = File.expand_path(File.join Rails.root, 'config', 'lita_config.rb')
    Lita.run(lita_config_path)
  end
end
