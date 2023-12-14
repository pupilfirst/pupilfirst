class PageRead < ApplicationRecord
  belongs_to :target
  belongs_to :student

  validates :student_id, uniqueness: { scope: :target_id }
end
