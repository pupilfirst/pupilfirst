module Answers
  class CreateService
    # @param user [User] user who is posting the answer
    # @param question [Question] question for which answer is being posted
    # @param description [String] body of the answer
    def initialize(user, question, description)
      @user = user
      @question = question
      @description = description
    end

    def create
      Answer.transaction do
        # Update the question's last activity time.
        @question.update!(last_activity_at: Time.zone.now)

        answer = Answer.create!(
          creator: @user,
          question: @question,
          description: @description
        )

        # If author of answer is different from author of question, notify them by mail.
        UserMailer.new_answer(answer).deliver_later if @user != @question.creator

        answer
      end
    end
  end
end
