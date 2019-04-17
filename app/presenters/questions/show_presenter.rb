module Questions
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)
      @question = question
    end

    def answers
      @question.answers
    end

    def answer_claps(answer)
      answer.answer_claps.pluck(:count).sum
    end

    def stars
      @question.answers.count
    end
  end
end
