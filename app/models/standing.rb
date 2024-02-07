class Standing < ApplicationRecord
  belongs_to :school
  has_many :user_standings, dependent: :restrict_with_error

  validates :name,
            presence: true,
            uniqueness: {
              scope: :school_id,
              message: I18n.t("schools.standings.form.unique_name_error")
            },
            length: {
              maximum: 25,
              message: I18n.t("schools.standings.form.name_max_length_error")
            }

  validates :description,
            presence: false,
            length: {
              maximum: 150,
              message:
                I18n.t("schools.standings.form.description_max_length_error")
            }

  validates :color, presence: true
  validates_with RateLimitValidator, limit: 15, scope: :school_id

  normalize_attributes :description, :name


  scope :live, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end
