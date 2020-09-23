module Types
  class VimeoVideo < Types::BaseObject
    field :upload_link, String, null: false
    field :link, String, null: false
  end
end
