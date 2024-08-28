# JSON fields schema:
#
# preferences: {
#   daily_digest: bool - default true. There may be users without this key.
# }
class User < ApplicationRecord
  acts_as_taggable

  belongs_to :school
  belongs_to :organisation, optional: true
  has_many :organisation_admins, dependent: :restrict_with_error
  has_many :organisations, through: :organisation_admins
  has_many :students, dependent: :restrict_with_error
  has_many :teams, through: :students
  has_many :cohorts, through: :students
  has_many :course_authors, dependent: :restrict_with_error
  has_many :communities, through: :students
  has_many :courses, through: :students
  has_one :faculty, dependent: :restrict_with_error
  has_one :school_admin, dependent: :restrict_with_error
  has_many :markdown_attachments, dependent: :nullify
  has_many :issued_certificates, dependent: :nullify
  has_many :locked_topics,
           class_name: "Topic",
           foreign_key: "locked_by_id",
           inverse_of: :locked_by,
           dependent: :nullify
  has_many :post_likes, dependent: :nullify
  has_many :text_versions, dependent: :nullify
  has_many :course_exports, dependent: :nullify
  has_many :created_posts,
           class_name: "Post",
           foreign_key: "creator_id",
           inverse_of: :creator,
           dependent: :nullify
  has_many :edited_posts,
           class_name: "Post",
           foreign_key: "editor_id",
           inverse_of: :editor,
           dependent: :nullify
  has_many :coach_notes,
           class_name: "CoachNote",
           foreign_key: "author_id",
           inverse_of: :author,
           dependent: :nullify
  has_many :topic_subscription, dependent: :destroy
  has_many :notifications,
           foreign_key: :recipient_id,
           inverse_of: :recipient,
           dependent: :destroy
  has_many :discord_messages, dependent: :destroy
  has_many :user_standings, dependent: :destroy

  has_many :submission_comments, dependent: :destroy
  has_many :moderation_reports, dependent: :destroy
  has_many :reactions, dependent: :destroy
  has_many :course_ratings, dependent: :destroy

  has_and_belongs_to_many :discord_roles,
                          join_table: "additional_user_discord_roles"

  # database_authenticable is required by devise_for to generate the session routes
  devise :database_authenticatable,
         :trackable,
         :rememberable,
         :omniauthable,
         :recoverable,
         omniauth_providers: %i[google_oauth2 facebook github discord]

  normalize_attribute :name, :about, :affiliation, :preferred_name

  validates :email,
            presence: true,
            email: true,
            uniqueness: {
              scope: :school_id
            }

  has_one_attached :avatar

  scope :with_email, ->(email) { where("lower(email) = ?", email.downcase) }

  before_save :capitalize_name_fragments

  def capitalize_name_fragments
    return unless name_changed?

    self.name =
      name
        .split
        .map do |name_fragment|
          name_fragment[0] = name_fragment[0].capitalize
          name_fragment
        end
        .join(" ")
  end

  attr_reader :delete_account_token_original
  attr_reader :api_token

  def regenerate_login_token
    @original_login_token = SecureRandom.urlsafe_base64
    update!(
      login_token_digest: Digest::SHA2.base64digest(@original_login_token),
      login_token_generated_at: Time.zone.now
    )
  end

  def original_login_token
    @original_login_token || raise("Original login token is unavailable")
  end

  def regenerate_reset_password_token
    @original_reset_password_token = SecureRandom.urlsafe_base64
    update!(
      reset_password_token:
        Digest::SHA2.base64digest(@original_reset_password_token)
    )
  end

  def original_reset_password_token
    @original_reset_password_token ||
      raise("Original reset password token is unavailable")
  end

  def regenerate_delete_account_token
    @delete_account_token_original = SecureRandom.urlsafe_base64
    update!(
      delete_account_token_digest:
        Digest::SHA2.hexdigest(@delete_account_token_original)
    )
  end

  def original_update_email_token
    @original_update_email_token ||
      raise("Original update email token is unavailable")
  end

  def regenerate_update_email_token
    @original_update_email_token = SecureRandom.urlsafe_base64
    update!(
      update_email_token:
        Digest::SHA2.base64digest(@original_update_email_token)
    )
  end

  def self.find_by_hashed_delete_account_token(delete_account_token)
    find_by(
      delete_account_token_digest: Digest::SHA2.hexdigest(delete_account_token)
    )
  end

  def self.find_by_hashed_update_email_token(token)
    find_by(update_email_token: token)
  end

  def regenerate_api_token
    @api_token = SecureRandom.urlsafe_base64
    update!(api_token_digest: Digest::SHA2.base64digest(@api_token))
  end

  def email_bounced?
    BounceReport.exists?(email: email)
  end

  def login_token_expiration_time
    (
      login_token_generated_at +
        Settings.login_token_time_limit
    ).in_time_zone(self.time_zone).strftime("%B %-d, %Y at %-l:%M %p")
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
      avatar.variant(resize_to_fill: [320, 320, crop: :attention]).processed
    when :thumb
      avatar.variant(resize_to_fill: [100, 100, crop: :attention]).processed
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
      Rails.application.routes.url_helpers.rails_public_blob_url(avatar)
    else
      Rails.application.routes.url_helpers.rails_public_blob_url(
        avatar_variant(variant)
      )
    end
  end

  # TODO: Remove User#image_or_avatar_url when all of its usages are gone. Use the avatar_url method instead, and generate initial avatars client-side.
  def image_or_avatar_url(variant: nil, background_shape: nil)
    Pupilfirst::Deprecation.warn("Use `avatar_url` instead")

    if avatar.attached?
      if variant.blank?
        Rails.application.routes.url_helpers.rails_public_blob_url(avatar)
      else
        Rails.application.routes.url_helpers.rails_public_blob_url(
          avatar_variant(variant)
        )
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

  def discord_account_connected?
    discord_user_id.present?
  end
end
