class CoursePolicy < ApplicationPolicy
  def leaderboard?
    true

    # return false if current_founder.blank?
    #
    # current_founder.course == record
  end
end
