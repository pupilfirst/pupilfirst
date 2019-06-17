module Types
  class CreateTargetType < Types::BaseObject
    field :id, ID, null: false
    field :content_block_id, ID, null: false
    field :sample_content, String, null: false
  end
end
