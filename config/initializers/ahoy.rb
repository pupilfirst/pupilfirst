module Ahoy
  class Store < Ahoy::Stores::ActiveRecordStore
    # User is actually 'founder' in our case.
    def user
      if controller.current_founder.present?
        @user ||= controller.current_founder
      else
        super
      end
    end
  end
end

# Disable geocoding. It isn't working. Plus, we don't really need it at the moment.
Ahoy.geocode = false

# Track visits across multiple subdomains.
Ahoy.cookie_domain = Rails.env.production? ? '.sv.co' : :all
