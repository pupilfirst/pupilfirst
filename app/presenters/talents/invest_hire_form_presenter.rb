module Talents
  class InvestHireFormPresenter < ApplicationPresenter
    def query_type_collection
      TalentForm::VALID_QUERY_TYPES.map do |query_type|
        OpenStruct.new(
          input_value: query_type,
          display_value: query_type
        )
      end
    end
  end
end
