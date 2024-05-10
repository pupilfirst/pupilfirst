module Types
  class SubmissionFileType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :url, String, null: false
    field :name, String, null: false

    def name
      object[:title]
    end
  end
end
