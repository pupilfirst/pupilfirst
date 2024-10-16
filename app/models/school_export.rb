class SchoolExport < ApplicationRecord
  belongs_to :school
  belongs_to :user,
             foreign_key: :created_by_id,
             optional: true,
             inverse_of: :school_exports

  has_one_attached :file
end
