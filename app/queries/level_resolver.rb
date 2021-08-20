class LevelResolver < ApplicationQuery
  include AuthorizeCoach

  property :level_id

  def level
    @level ||= Level.find_by(id: level_id)
  end

  private

  def authorized?
    level_id.present? ? super : true
  end

  def course
    @course ||= level&.course
  end
end
