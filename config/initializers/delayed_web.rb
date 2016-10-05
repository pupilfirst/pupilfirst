# Tell Delayed::Web that we're using ActiveRecord as our backend.
Rails.application.config.to_prepare do
  Delayed::Web::Job.backend = 'active_record'
end
