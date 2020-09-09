module Types
  class VimeoVideo < Types::BaseObject
    field :upload_link, String, null: false
    field :uri, String, null: false
  end
end
