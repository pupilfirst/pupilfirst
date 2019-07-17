module Comments
  class CreateService
    # @param user [User] user who is posting the comment
    # @param commentable [Question, Answer] question or answer on which the comment is being posted
    # @param value [String] body of the comment
    def initialize(user, commentable, value)
      @user = user
      @commentable = commentable
      @value = value
    end

    def create
      Comment.transaction do
        # Update the commentable's last activity time.
        @commentable.update!(last_activity_at: Time.zone.now) if @commentable.is_a?(Question)

        comment = Comment.create!(
          creator: @user,
          commentable: @commentable,
          value: @value
        )

        # If author of comment is different from author of commentable, notify them by mail.
        UserMailer.new_comment(comment).deliver_later if @user != @commentable.creator

        comment
      end
    end
  end
end
