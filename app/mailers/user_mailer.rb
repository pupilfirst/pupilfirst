class UserMailer < SchoolMailer
  # Mail sent to community user when a new comments is posted to one of their questions / answers.
  #
  # @param post [Post] The new post on a community topic.
  # @param addressee [User] The user being replied to using the post.
  def new_post(post, addressee)
    @post = post
    @addressee = addressee
    @school = addressee.school
    simple_mail(addressee.email, I18n.t('mailers.user.new_post.subject'))
  end

  # Mail sent daily to users when there are new questions posted in communities where they have access.
  #
  # @param user [User] user to whom digest is to be sent
  # @param updates [Hash] digest details
  def daily_digest(user, updates)
    @user = user
    @updates = updates
    @school = user.school
    subject =
      "#{user.school.name}: #{I18n.t('mailers.user.daily_digest.subject')} - #{Time.zone.now.strftime('%b %-d, %Y')}"
    simple_mail(user.email, subject)
  end

  def delete_account_token(user, delete_account_url)
    @user = user
    @school = user.school
    @delete_account_url = delete_account_url
    simple_mail(
      user.email,
      I18n.t(
        'mailers.user.delete_account_token.subject',
        school_name: @school.name
      )
    )
  end

  def confirm_account_deletion(name, email, school)
    @name = name
    @email = email
    @school = school
    simple_mail(
      email,
      I18n.t(
        'mailers.user.confirm_account_deletion.subject',
        school_name: @school.name
      )
    )
  end

  def account_deletion_notification(user, sign_in_url, inactivity_months)
    @user = user
    @school = user.school
    @inactivity_months = inactivity_months
    @sign_in_url = sign_in_url
    simple_mail(
      user.email,
      I18n.t('mailers.user.account_deletion_notification.subject')
    )
  end
end
