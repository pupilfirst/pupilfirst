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
  has_one :school_admin, dependent: :restrict_with_error
  has_many :markdown_attachments, dependent: :nullify
  has_many :issued_certificates, dependent: :nullify
  has_many :locked_topics, class_name: 'Topic', foreign_key: 'locked_by_id', inverse_of: :locked_by, dependent: :nullify
  has_many :post_likes, dependent: :nullify
  has_many :text_versions, dependent: :nullify
  has_many :course_exports, dependent: :nullify
  has_many :created_posts, class_name: 'Post', foreign_key: 'creator_id', inverse_of: :creator, dependent: :nullify
  has_many :edited_posts, class_name: 'Post', foreign_key: 'editor_id', inverse_of: :editor, dependent: :nullify
  has_many :coach_notes, class_name: 'CoachNote', foreign_key: 'author_id', inverse_of: :author, dependent: :nullify
  has_many :topic_subscription, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, inverse_of: :recipient, dependent: :destroy

  has_secure_token :login_token
  has_secure_token :reset_password_token
  has_secure_token :delete_account_token

  # database_authenticable is required by devise_for to generate the session routes
  devise :database_authenticatable, :trackable, :rememberable, :omniauthable, :recoverable,
    omniauth_providers: %i[google_oauth2 facebook github]

  normalize_attribute :name, :about, :affiliation

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

  attr_reader :delete_account_token_original
  attr_reader :api_token

  def regenerate_delete_account_token
    @delete_account_token_original = SecureRandom.urlsafe_base64
    update!(delete_account_token: Digest::SHA2.hexdigest(@delete_account_token_original))
  end

  def self.find_by_hashed_delete_account_token(delete_account_token)
    find_by(delete_account_token: Digest::SHA2.hexdigest(delete_account_token))
  end

  def regenerate_api_token
    @api_token = SecureRandom.urlsafe_base64
    update!(api_token_digest: Digest::SHA2.base64digest(@api_token))
  end

  def email_bounced?
    BounceReport.exists?(email: email)
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
            resize: '320x320^',
            crop: '320x320+0+0'
          })
      when :thumb
        avatar.variant(combine_options:
          {
            auto_orient: true,
            gravity: 'center',
            resize: '100x100^',
            crop: '100x100+0+0'
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
