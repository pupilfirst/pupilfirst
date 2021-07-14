class TargetInfoResolver < ApplicationQuery
  include AuthorizeCoach

  property :target_id

  def target_info
    @target_info ||= Target.find_by(id: target_id)
  end

  private

  def authorized?
    target_id.present? ? super : true
  end

  def course
    @course ||= target_info&.course
  end
end
