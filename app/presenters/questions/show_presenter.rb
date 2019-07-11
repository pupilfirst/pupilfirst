module Questions
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)
      @question = question
    end

    def props
      {
        authenticity_token: view.form_authenticity_token,
        questions: question_data,
        answers: answer_data,
        comments: comments,
        userData: user_data,
        likes: likes,
        currentUser_id: current_user.id,
        community_path: view.community_path(community),
        is_coach: current_coach.present?,
        community_id: community.id
      }
    end

    def page_title
      "#{question_data['title']} | Question"
    end

    def question_data
      @question.attributes.slice('id', 'title', 'description', 'creator_id', 'editor_id', 'created_at', 'updated_at')
    end

    def answer_data
      attributes = %w[id creator_id editor_id description archived created_at updated_at]
      @answer_data ||=
        @question.answers.live.select(*attributes).map do |answer|
          answer.attributes.slice(*attributes)
        end
    end

    def comments
      @comments ||=
        @question.comments.live.map(&method(:comment_data)) + comments_for_answers
    end

    def comments_for_answers
      Comment.live.where(commentable_type: Answer.to_s, commentable_id: @answer_data.pluck('id'))
        .map(&method(:comment_data))
    end

    def comment_data(comment)
      comment.attributes.slice('id', 'value', 'creator_id', 'archived', 'commentable_type', 'commentable_id', 'created_at')
    end

    def user_data
      user_ids = [@question.creator_id, @question.editor_id, answer_data.pluck('creator_id'), answer_data.pluck('editor_id'), comments.pluck('creator_id'), current_user.id]
        .flatten.uniq

      UserProfile.where(user_id: user_ids, school: current_school).with_attached_avatar
        .includes([user: :faculty]).map do |user_profile|
        user_profile.attributes.slice('user_id', 'name').merge(
          avatar_url: avatar_url(user_profile),
          title: title(user_profile)
        )
      end
    end

    def likes
      AnswerLike.where(answer_id: answer_data.pluck('id')).map do |like|
        like.attributes.slice('id', 'answer_id', 'user_id')
      end
    end

    def community
      @community ||= @question.community
    end

    private

    def title(user_profile)
      title = user_profile.title
      title_text = title.present? ? ", #{title}" : ""

      if user_profile.user.faculty.any?
        title.presence || "Coach"
      else
        "Student#{title_text}"
      end
    end

    def avatar_url(user_profile)
      if user_profile.avatar.attached?
        view.url_for(user_profile.avatar_variant(:mid))
      else
        user_profile.initials_avatar
      end
    end
  end
end
