class Domain < ApplicationRecord
  belongs_to :school

  def self.primary
    find_by(primary: true) || first
  end
end
