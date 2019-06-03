class UpdateQuestionMutator < ApplicationMutator
  include AuthorizeCommunityUser

  attr_accessor :id
  attr_accessor :title
  attr_accessor :description

  validates :title, length: { minimum: 1, maximum: 250, message: 'InvalidLengthTitle' }, allow_nil: false
  validates :description, length: { minimum: 1, message: 'InvalidLengthDescription' }, allow_nil: false

  def update_question
    question.text_versions.create!(value: question.description, user: question.creator, edited_at: question.updated_at)
    question.update!(title: title, description: description, editor: current_user)
  end

  private

  alias authorized? authorized_update?

  def community
    @community ||= question&.community
  end

  def creator
    question&.creator
  end

  def question
    @question ||= Question.find_by(id: id)
  end
end
