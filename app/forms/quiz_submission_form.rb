class QuizSubmissionForm < Reform::Form
  collection :questions, virtual: true do
    property :answer_id, virtual: true
  end

  def prepopulate!(options)
    self.questions = options[:questions]
  end
end
