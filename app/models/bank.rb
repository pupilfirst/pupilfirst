class Bank < ActiveRecord::Base
  has_many :directors, class_name: 'User'
  belongs_to :startup
end
