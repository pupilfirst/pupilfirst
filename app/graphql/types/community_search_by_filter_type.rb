module Types
  class CommunitySearchByFilterType < Types::BaseEnum
    value 'title', 'To search for topics by title'
    value 'content', 'To search for topics by post body'
  end
end
