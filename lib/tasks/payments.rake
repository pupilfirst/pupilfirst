namespace :payments do
  desc 'Create payment and remind startup founders to pay the fee when their subscription is close to expiry'
  task billing: :environment do
    Payments::BillingService.new.execute
  end
end
