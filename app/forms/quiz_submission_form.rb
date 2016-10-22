class QuizSubmissionForm < Reform::Form
  collection :questions do
    property :answer_id, virtual: true
  end

  def prepopulate!(options)
    self.questions = options[:questions]
  end
end
