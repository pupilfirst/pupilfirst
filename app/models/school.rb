class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :startups, through: :courses
  has_many :founders, through: :courses
  has_many :school_admins, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :faculty, dependent: :destroy
  has_many :school_strings, dependent: :destroy
  has_many :school_links, dependent: :destroy
  has_many :user_profiles, dependent: :destroy

  acts_as_taggable_on :founder_tags

  has_one_attached :logo_on_light_bg
  has_one_attached :logo_on_dark_bg
  has_one_attached :icon

  def logo_variant(variant, background: :light)
    logo = background == :light ? logo_on_light_bg : logo_on_dark_bg

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

  def icon_variant(variant)
    case variant
      when :thumb
        icon.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '100x100>'
          })
      else
        icon
    end
  end
end
