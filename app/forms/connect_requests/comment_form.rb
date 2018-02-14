module ConnectRequests
  class CommentForm < Reform::Form
    attr_accessor :from

    property :comment, virtual: true, validates: { presence: true, length: { maximum: 500 } }

    def save
      comment_save = if from == :team
        { comment_for_faculty: comment }
      else
        { comment_for_team: comment }
      end

      model.update(comment_save)
    end
  end
end
