class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :startups, through: :courses
  has_many :founders, through: :courses
  has_many :school_admins, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :faculty, dependent: :destroy
  has_many :school_strings, dependent: :destroy
end
