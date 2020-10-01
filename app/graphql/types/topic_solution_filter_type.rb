module Types
  class TopicSolutionFilterType < Types::BaseEnum
    value 'HasSolution', 'To select topics who that has a solution marked'
    value 'WithoutSolution', 'To select topics that do not have a solution marked'
    value 'IgnoreSolution', 'To select topics regardless of having solution or not'
  end
end
