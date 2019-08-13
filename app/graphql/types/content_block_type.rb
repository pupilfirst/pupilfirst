module Types
  class ContentBlockType < Types::BaseObject
    field :id, ID, null: false
    field :block_type, String, null: false
    field :sort_index, Integer, null: false
    field :content, Types::ContentType, null: false
    field :file, Types::ContentFileAttachmentType, null: true

    def file
      return unless object.file.attached?

      { url: url_helpers.rails_blob_path(object.file, only_path: true), name: object.file.filename }
    end
  end
end
