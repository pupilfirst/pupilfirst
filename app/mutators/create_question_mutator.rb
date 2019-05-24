class CreateQuestionMutator < ApplicationMutator
  attr_accessor :title
  attr_accessor :description
  attr_accessor :community_id
  attr_accessor :target_id

  validates :title, length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false
  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false
  validates :community_id, presence: { message: 'BlankCommunityID' }

  def create_question
    question = Question.create!(
      title: title,
      description: description,
      creator: current_user,
      community: community
    )

    create_target_question(question) if target_id.present?

    question.id
  end

  def authorized?
    #  Can't ask questions at PupilFirst., current user must exist, Can only ask questions in the same school.
    return false unless current_school.present? && current_user.present? && (community&.school == current_school)

    # Coach has access to all communities
    return true if current_coach.present?

    # User should have access to the community
    current_user.founders.includes(:course).where(courses: { id: community.courses }).any?
  end

  private

  def community
    @community ||= Community.find_by(id: community_id)
  end

  def create_target_question(question)
    target = Target.find_by(id: target_id)
    TargetQuestion.create!(question: question, target: target)
  end
end
