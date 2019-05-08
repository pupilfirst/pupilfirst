class CreateQuestionMutator < ApplicationMutator
  include ActiveSupport::Concern

  attr_accessor :title
  attr_accessor :description
  attr_accessor :community_id

  validates :title, length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false
  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false
  validates :community_id, presence: { message: 'BlankCommunityID' }

  def create_question
    question = Question.create!(
      title: title,
      description: description,
      user: current_user,
      community: community
    )
    question.id
  end

  def authorized?
    # Can't ask questions at PupilFirst.
    raise UnauthorizedMutationException if current_school.blank?

    # Only a student or coach can ask a question.
    raise UnauthorizedMutationException if current_founder.blank? && current_coach.blank?

    # Can only ask questions in the same school.
    raise UnauthorizedMutationException if community&.school != current_school

    true
  end

  private

  def community
    @community ||= Community.find_by(id: community_id)
  end
end
