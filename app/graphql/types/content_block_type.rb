module Types
  class ContentBlockType < Types::BaseObject
    field :id, ID, null: false
    field :block_type, String, null: false
    field :sort_index, Integer, null: false
    field :content, Types::ContentType, null: false

    def content
      content = { block_type: object.block_type }.merge(object.content)
      content.merge!(file_details) if object.file.attached?
      content
    end

    def file_details
      { url: Rails.application.routes.url_helpers.rails_blob_path(object.file, only_path: true), filename: object.file.filename.to_s }
    end
  end
end
