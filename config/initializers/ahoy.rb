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

# Do geocoding offline. https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = :async
