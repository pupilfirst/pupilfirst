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

  # Mail sent to community user when a new comments is posted to one of their questions / answers.
  #
  # @param post [Post] The new post on a community topic.
  # @param addressee [User] The user being replied to using the post.
  def new_post(post, addressee)
    @post = post
    @addressee = addressee
    @school = addressee.school
    simple_roadie_mail(addressee.email, 'New reply for your post')
  end

  # Mail sent daily to users when there are new questions posted in communities where they have access.
  #
  # @param user [User] user to whom digest is to be sent
  # @param updates [Hash] digest details
  def daily_digest(user, updates)
    @user = user
    @updates = updates
    @school = user.school
    subject = "#{user.school.name}: Daily Digest - #{Time.zone.now.strftime('%b %-d, %Y')}"
    simple_roadie_mail(user.email, subject)
  end
end
