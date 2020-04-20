class SchoolAdmin < ApplicationRecord
  belongs_to :user
  belongs_to :school

  delegate :name, :email, :title, to: :user
end
