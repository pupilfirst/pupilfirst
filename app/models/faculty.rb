class Faculty < ActiveRecord::Base
  mount_uploader :image, FacultyImageUploader
  process_in_background :image

  CATEGORY_TEAM = 'team'
  CATEGORY_VISITING_FACULTY = 'visiting_faculty'
  CATEGORY_ADVISORY_BOARD = 'advisory_board'

  def self.valid_categories
    [CATEGORY_TEAM, CATEGORY_VISITING_FACULTY, CATEGORY_ADVISORY_BOARD]
  end
end
