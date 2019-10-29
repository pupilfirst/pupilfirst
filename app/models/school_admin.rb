class SchoolAdmin < ApplicationRecord
  belongs_to :user
  belongs_to :school

  delegate :name, to: :user
end
