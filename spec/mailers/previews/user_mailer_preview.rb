class UserMailerPreview < ActionMailer::Preview
  def new_answer
    UserMailer.new_answer(Answer.order('RANDOM()').first)
  end

  def new_comment
    UserMailer.new_comment(Comment.order('RANDOM()').first)
  end
end
