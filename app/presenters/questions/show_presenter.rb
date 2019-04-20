module Questions
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)
      @question = question
    end

    def show_edit_button?
      @question.user == current_user
    end

    def show_answer_edit?(answer)
      answer.user == current_user
    end

    def answers
      @question.answers.includes([:answer_claps, user: :faculty]).order("answer_claps.count DESC NULLS LAST")
    end

    def answer_claps(answer)
      answer.answer_claps.pluck(:count).sum
    end

    def answers_count
      @question.answers.count
    end

    def time(object)
      object.created_at.to_formatted_s(:long)
    end

    def user_image(user)
      profile = user_profile(user)
      profile.avatar.attached? ? profile.avatar.blob : profile.initials_avatar(:square)
    end

    def name(user)
      user_profile(user).name
    end

    def title(user)
      title = user_profile(user).title
      title_text = title.present? ? ", #{title}" : ""

      if user.faculty.present?
        "Faculty #{title_text}"
      else
        "Student #{title_text}"
      end
    end

    def user_profile(user)
      user.user_profiles.where(school: current_school).first
    end
  end
end
