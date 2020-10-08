module Types
  class TopicSortCriterionType < Types::BaseEnum
    value 'CreatedAt', 'Sort list of topics by creation time'
    value 'LastActivityAt', 'Sort list of topics by last activity time'
    value 'Views', 'Sort list of topics by number of views'
  end
end
