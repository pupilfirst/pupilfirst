class CommunityCourseConnection < ApplicationRecord
  belongs_to :community
  belongs_to :course
end
