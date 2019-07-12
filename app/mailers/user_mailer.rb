class UserMailer < SchoolMailer
  # Mail sent to community user when a new answer is posted to one of their questions.
  #
  # @param answer [Answer] The newly posted answer.
  def new_answer(answer)
    @answer = answer
    @school = @answer.school
    simple_roadie_mail(answer.question.creator.email, 'New answer for your question')
  end

  # Mail sent to community user when a new comments is posted to one of their questions / answers.
  #
  # @param comment [Comment] The newly posted comment.
  def new_comment(comment)
    @comment = comment
    @school = @comment.commentable.school
    simple_roadie_mail(comment.commentable.creator.email, 'New comment on your post')
  end
end
