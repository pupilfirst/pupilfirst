module Comments
  class CreateService
    # @param user [User] user who is posting the comment
    # @param commentable [Question, Answer] question or answer on which the comment is being posted
    # @param value [String] body of the comment
    def new(user, commentable, value)
      @user = user
      @commentable = commentable
      @value = value
    end

    def create
      Comment.transaction do
        # Update the commentable's last activity time.
        @commentable.update!(last_activity_at: Time.zone.now) if commentable_type == Question.name

        comment = Comment.create!(
          creator: current_user,
          commentable: commentable,
          value: value
        )

        # Notify the author of the commentable about the new comment.
        UserMailer.new_comment(comment).deliver_later

        comment
      end
    end
  end
end
