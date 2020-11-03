module Types
  class EmbedRequestSource < Types::BaseEnum
    value 'User', 'An embed whose source URL has been supplied by the user'
    value 'VimeoUpload', 'An embed whose source URL has been generated as a result of an upload to Vimeo'
  end
end
