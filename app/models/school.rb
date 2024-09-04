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
  has_many :standings, dependent: :destroy
  has_many :discord_roles, dependent: :destroy
  has_many :course_categories, dependent: :destroy

  acts_as_taggable_on :student_tags
  acts_as_taggable_on :user_tags

  normalize_attribute :about

  has_one_attached :logo_on_light_bg
  has_one_attached :logo_on_dark_bg
  has_one_attached :icon_on_light_bg
  has_one_attached :icon_on_dark_bg
  has_one_attached :cover_image

  scope :beckn_enabled, -> { where(beckn_enabled: true) }

  def school_admins
    SchoolAdmin.joins(:user).where(users: { school_id: id })
  end

  def logo_variant(variant, background: :light)
    logo = background == :light ? logo_on_light_bg : logo_on_dark_bg

    case variant
    when :mid
      logo.variant(resize_to_limit: [nil, 200]).processed
    when :high
      logo.variant(resize_to_limit: [nil, 500]).processed
    when :thumb
      logo.variant(resize_to_limit: [nil, 100]).processed
    else
      logo
    end
  end

  def icon_variant(variant, background: :light)
    icon = background == :light ? icon_on_light_bg : icon_on_dark_bg
    case variant
    when :thumb
      icon.variant(resize_to_limit: [100, 100]).processed
    else
      icon
    end
  end

  def email
    SchoolString::EmailAddress.for(self)
  end

  def default_standing
    standings.find_by(default: true)
  end

  def default_discord_role_ids
    discord_roles.where(default: true).pluck(:discord_id)
  end
end
