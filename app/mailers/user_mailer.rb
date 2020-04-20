class UserMailer < SchoolMailer
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
