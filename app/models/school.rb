class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :startups, through: :courses
  has_many :founders, through: :courses
  has_many :school_admins, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :faculty, dependent: :destroy
  has_many :school_strings, dependent: :destroy

  acts_as_taggable_on :founder_tags
  has_one_attached :logo

  def logo_variant(variant)
    case variant
      when :mid
        logo.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '200x200>'
          })
      when :thumb
        logo.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '100x100>'
          })
      else
        logo
    end
  end
end
