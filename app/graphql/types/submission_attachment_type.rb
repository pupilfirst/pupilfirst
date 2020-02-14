module Types
  class SubmissionAttachmentType < Types::BaseObject
    field :title, String, null: false
    field :url, String, null: false
  end
end
