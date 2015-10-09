class Faculty < ActiveRecord::Base
  mount_uploader :image, FacultyImageUploader
  process_in_background :image

  has_many :startup_feedback, dependent: :restrict_with_error

  CATEGORY_TEAM = 'team'
  CATEGORY_VISITING_FACULTY = 'visiting_faculty'
  CATEGORY_ADVISORY_BOARD = 'advisory_board'

  validates_presence_of :name, :title, :category, :image

  def self.valid_categories
    [CATEGORY_TEAM, CATEGORY_VISITING_FACULTY, CATEGORY_ADVISORY_BOARD]
  end

  validates_inclusion_of :category, in: valid_categories
  validate :availability_check

  # When available_for_connect is set, availability must be mentioned.
  def availability_check
    return unless available_for_connect
    return unless availability.blank?
    errors.add(:availability, 'must be set to mark faculty member as available')
  end

  scope :team, -> { where(category: CATEGORY_TEAM).order('sort_index ASC') }
  scope :visiting_faculty, -> { where(category: CATEGORY_VISITING_FACULTY).order('sort_index ASC') }
  scope :advisory_board, -> { where(category: CATEGORY_ADVISORY_BOARD).order('sort_index ASC') }

  def display_name
    name
  end
end
