module Answers
  class CreateOrUpdateForm < Reform::Form
    property :description, validates: { presence: true }

    def save
      sync
      model.save!
      model
    end
  end
end
