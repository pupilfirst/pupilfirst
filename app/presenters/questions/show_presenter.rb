module Questions
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)
      @question = question
    end

    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        questions: question_data,
        answers: answer_data,
        comments: comments,
        userData: user_data
      }.to_json
    end

    def question_data
      {
        id: @question.id,
        title: @question.title,
        description: @question.description,
        userId: @question.user_id
      }
    end

    def answer_data
      @answer_data ||=
        @question.answers.map do |answer|
          {
            id: answer.id,
            description: answer.description,
            userId: answer.user_id
          }
        end
    end

    def comments
      @comments ||=
        @question.comments.map(&method(:comment_data)) + comments_for_answers
    end

    def comments_for_answers
      Comment.where(commentable_type: "Answer", commentable_id: @answer_data.pluck(:id)).map(&method(:comment_data))
    end

    def comment_data(comment)
      {
        id: comment.id,
        value: comment.value,
        user_id: comment.user_id,
        commentableType: comment.commentable_type,
        commentableId: comment.commentable_id

      }
    end

    def user_data
      user_ids = ([@question.id] + @answer_data.pluck(:userId) + @comments.pluck(:userId)).uniq
      UserProfile.where(user_id: user_ids, school: current_school).map do |user_profile|
        {
          id: user_profile.user_id,
          name: user_profile.name
        }
      end
    end
  end
end
