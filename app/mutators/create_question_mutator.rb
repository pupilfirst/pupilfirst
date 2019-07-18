class CreateQuestionMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :title
  attr_accessor :description
  attr_accessor :community_id
  attr_accessor :target_id

  validates :title, length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false
  validates :description, length: { minimum: 1, maximum: 15_000, message: 'InvalidLengthDescription' }, allow_nil: false
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
