class Startup < ActiveRecord::Base
  MAX_PITCH_WORDS = 10
  MAX_ABOUT_WORDS = 500

	has_many :founders, :class_name => "User", :foreign_key => "startup_id"
	has_and_belongs_to_many :categories, :join_table => "startups_categories"

	validate :valid_categories?
  validates_presence_of :name
  validates_presence_of :logo
  validates_presence_of :email
  validates_presence_of :phone
  validates_length_of :pitch, :within => 2..MAX_PITCH_WORDS, :message => "must be within 2 to #{MAX_PITCH_WORDS} words", tokenizer: ->(str) { str.scan(/\w+/) }, allow_nil: false
  validates_length_of :about, :within => 10..MAX_ABOUT_WORDS, :message => "must be within 10 to #{MAX_ABOUT_WORDS} words", tokenizer: ->(str) { str.scan(/\w+/) }, allow_nil: false

	def valid_categories?
   self.errors.add(:categories, "cannot have more than 3 categories") if categories.size > 3
   self.errors.add(:categories, "must have atleast one category") if categories.size < 1
	end

  mount_uploader :logo, AvatarUploader
  accepts_nested_attributes_for :founders
  normalize_attribute :name, :pitch, :about, :email, :phone
end
