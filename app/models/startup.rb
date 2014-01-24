class Startup < ActiveRecord::Base
	has_many :founders, :class_name => "User", :foreign_key => "startup_id"
	has_and_belongs_to_many :categories, :join_table => "startups_categories"

	validate :valid_categories?
  validates_presence_of :name
  validates_presence_of :logo
  validates_presence_of :pitch
  validates_presence_of :about
  validates_presence_of :email
  validates_presence_of :phone

	# validates :categories, length: { in: 1..3 }

	def valid_categories?
   self.errors.add(:categories, "cannot have more than 3 categories") if categories.size > 3
   self.errors.add(:categories, "must have atleast one category") if categories.size < 1
	end

  mount_uploader :logo, AvatarUploader
  accepts_nested_attributes_for :founders
  normalize_attribute :name, :pitch, :about, :email, :phone
end
