class UpdateAnswerMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :id
  attr_accessor :description

  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false

  def update_answer
    answer.text_versions.create!(value: answer.description, user: answer.creator, edited_at: answer.updated_at)
    answer.update!(description: description, editor: current_user)
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= answer&.community
  end

  def creator
    answer&.creator
  end

  def answer
    @answer ||= Answer.find_by(id: id)
  end
end
