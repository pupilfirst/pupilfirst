class SchoolAdmin < ApplicationRecord
  belongs_to :user
  delegate :school, :name, :email, :title, to: :user
end
