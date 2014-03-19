class Guardian < ActiveRecord::Base
  belongs_to :name
  belongs_to :address
  accepts_nested_attributes_for :name, :address

end
