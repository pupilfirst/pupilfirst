module Ahoy
  class Store < Ahoy::Stores::ActiveRecordStore
    def user
      if controller.current_founder.present?
        @user ||= controller.current_founder
      else
        super
      end
    end
  end
end
