class CreateQuestionMutator < ApplicationQuery
  include AuthorizeCommunityUser

  property :title, validates: { length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false }
  property :description, validates: { length: { minimum: 1, maximum: 15_000, message: 'InvalidLengthDescription' }, allow_nil: false }
  property :community_id, validates: { presence: { message: 'BlankCommunityID' } }
  property :target_id

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

  private

  alias authorized? authorized_create?

  def community
    @community ||= Community.find_by(id: community_id)
  end

  def create_target_question(question)
    target = Target.find_by(id: target_id)
    TargetQuestion.create!(question: question, target: target)
  end
end
