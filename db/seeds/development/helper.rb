# Let's activate Faker.
if require 'faker'
  # ...and reload I18n, cuz' that seems to be the only way to get Faker to work. https://github.com/stympy/faker/issues/285
  I18n.reload!
end

# Disable emails.
ActionMailer::Base.perform_deliveries = false
