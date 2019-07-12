class UserProfile < ApplicationRecord
  belongs_to :user
  belongs_to :school

  GENDER_MALE = 'male'.freeze
  GENDER_FEMALE = 'female'.freeze
  GENDER_OTHER = 'other'.freeze

  normalize_attribute :name, :gender, :phone, :communication_address, :title, :key_skills, :about,
    :resume_url, :blog_url, :personal_website_url, :linkedin_url, :twitter_url, :facebook_url,
    :angel_co_url, :github_url, :behance_url, :skype_id

  has_one_attached :avatar

  alias image avatar

  def self.valid_gender_values
    [GENDER_MALE, GENDER_FEMALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }, allow_nil: true

  before_save :capitalize_name_fragments

  def capitalize_name_fragments
    return unless name_changed?

    self.name = name.split.map do |name_fragment|
      name_fragment[0] = name_fragment[0].capitalize
      name_fragment
    end.join(' ')
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
end
