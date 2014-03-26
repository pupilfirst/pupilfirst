class Address < ActiveRecord::Base
  has_one :startup, as: :registered_address
end
