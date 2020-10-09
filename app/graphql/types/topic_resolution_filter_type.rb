module Types
  class TopicResolutionFilterType < Types::BaseEnum
    value 'Solved', 'To select topics that has a solution marked'
    value 'Unsolved', 'To select topics that do not have a solution marked'
    value 'Unselected', 'To select topics without regard for resolution'
  end
end
