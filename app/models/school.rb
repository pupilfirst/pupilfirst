class School < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :organisations, dependent: :destroy
  has_many :courses, dependent: :restrict_with_error
  has_many :cohorts, through: :courses
  has_many :students, through: :users
  has_many :teams, through: :courses
  has_many :faculty, through: :users
  has_many :domains, dependent: :destroy
  has_many :school_strings, dependent: :destroy
  has_many :school_links, dependent: :destroy
  has_many :communities, dependent: :destroy
  has_many :levels, through: :courses
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :timeline_events, through: :students
  has_many :markdown_attachments, dependent: :destroy
  has_many :audit_records, dependent: :destroy
  has_many :calendars, through: :courses
  has_many :calendar_events, through: :calendars

  acts_as_taggable_on :student_tags
  acts_as_taggable_on :user_tags

  normalize_attribute :about

  has_one_attached :logo_on_light_bg
  has_one_attached :logo_on_dark_bg
  has_one_attached :icon
  has_one_attached :cover_image

  def school_admins
    SchoolAdmin.joins(:user).where(users: { school_id: id })
  end

  def logo_variant(variant, background: :light)
    logo = background == :light ? logo_on_light_bg : logo_on_dark_bg

    case variant
    when :mid
      logo.variant(
        auto_orient: true,
        gravity: "center",
        resize: "200x200>"
      ).processed
    when :high
      logo.variant(
        auto_orient: true,
        gravity: "center",
        resize: "500x500>"
      ).processed
    when :thumb
      logo.variant(
        auto_orient: true,
        gravity: "center",
        resize: "100x100>"
      ).processed
    else
      logo
    end
  end

  def icon_variant(variant)
    case variant
    when :thumb
      icon.variant(
        auto_orient: true,
        gravity: "center",
        resize: "100x100>"
      ).processed
    else
      icon
    end
  end
end
