class UserMailerPreview < ActionMailer::Preview
  def new_answer
    UserMailer.new_answer(Answer.first)
  end

  def new_comment
    UserMailer.new_comment(Comment.first)
  end
end
