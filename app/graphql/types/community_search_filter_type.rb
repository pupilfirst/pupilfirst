module Types
  class CommunitySearchFilterType < Types::BaseInputObject
    argument :search, String, required: true
    argument :search_by, Types::CommunitySearchByFilterType, required: true
  end
end
