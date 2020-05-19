# JSON fields schema:
#
# preferences: {
#   daily_digest: bool - default true. There may be users without this key.
# }
class User < ApplicationRecord
  belongs_to :school
  has_many :founders, dependent: :restrict_with_error
  has_many :startups, through: :founders
  has_many :course_authors, dependent: :restrict_with_error
  has_many :communities, through: :founders
  has_many :courses, through: :founders
  has_one :faculty, dependent: :restrict_with_error
  has_many :user_activities, dependent: :destroy
  has_many :visits, as: :user, dependent: :destroy, inverse_of: :user
  has_one :school_admin, dependent: :restrict_with_error
  has_many :markdown_attachments, dependent: :restrict_with_error
  has_many :issued_certificates, dependent: :restrict_with_error

  has_secure_token :login_token
  has_secure_token :reset_password_token

  # database_authenticable is required by devise_for to generate the session routes
  devise :database_authenticatable, :trackable, :rememberable, :omniauthable, :recoverable,
    omniauth_providers: %i[google_oauth2 facebook github]

  normalize_attribute :name, :phone, :communication_address, :key_skills, :about,
    :resume_url, :blog_url, :personal_website_url, :linkedin_url, :twitter_url, :facebook_url,
    :angel_co_url, :github_url, :behance_url, :skype_id, :affiliation

  validates :email, presence: true, email: true, uniqueness: { scope: :school_id }

  has_one_attached :avatar

  scope :with_email, ->(email) { where('lower(email) = ?', email.downcase) }

  before_save :capitalize_name_fragments

  def capitalize_name_fragments
    return unless name_changed?

    self.name = name.split.map do |name_fragment|
      name_fragment[0] = name_fragment[0].capitalize
      name_fragment
    end.join(' ')
  end

  def email_bounced?
    BounceReport.where(email: email).exists?
  end

  # True if the user has ever signed in, handled by Users::ConfirmationService.
  def confirmed?
    confirmed_at.present?
  end

  def display_name
    email
  end

  def avatar_variant(version)
    case version
      when :mid
        avatar.variant(combine_options:
          {
            auto_orient: true,
            gravity: "center",
            resize: '200x200^',
            crop: '200x200+0+0'
          })
      when :thumb
        avatar.variant(combine_options:
          {
            auto_orient: true,
            gravity: 'center',
            resize: '50x50^',
            crop: '50x50+0+0'
          })
      else
        avatar
    end
  end

  def initials_avatar(background_shape: nil)
    logo = Scarf::InitialAvatar.new(name, background_shape: background_shape)
    "data:image/svg+xml;base64,#{Base64.encode64(logo.svg)}"
  end

  def avatar_url(variant: nil)
    return unless avatar.attached?

    if variant.blank?
      Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
    else
      Rails.application.routes.url_helpers.rails_representation_path(avatar_variant(variant), only_path: true)
    end
  end

  # TODO: Remove User#image_or_avatar_url when all of its usages are gone. Use the avatar_url method instead, and generate initial avatars client-side.
  def image_or_avatar_url(variant: nil, background_shape: nil)
    ActiveSupport::Deprecation.warn('Use `avatar_url` instead')

    if avatar.attached?
      if variant.blank?
        Rails.application.routes.url_helpers.rails_blob_path(avatar, only_path: true)
      else
        Rails.application.routes.url_helpers.rails_representation_path(avatar_variant(variant), only_path: true)
      end
    else
      initials_avatar(background_shape: background_shape)
    end
  end

  def full_title
    if title.present? && affiliation.present?
      "#{title}, #{affiliation}"
    else
      title.presence || affiliation.presence
    end
  end
end
