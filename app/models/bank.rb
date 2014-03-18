class Bank < ActiveRecord::Base
  belongs_to :directors, class_name: 'User'
  belongs_to :startup
end
