module Types
  class SubmissionAttachmentType < Types::BaseObject
    field :title, String, null: true
    field :url, String, null: false
  end
end
