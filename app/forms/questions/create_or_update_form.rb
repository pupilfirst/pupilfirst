module Questions
  class CreateOrUpdateForm < Reform::Form
    property :title, validates: { presence: true, length: { maximum: 250 } }
    property :description, validates: { presence: true }

    def save
      sync
      model.save!
      model
    end
  end
end
