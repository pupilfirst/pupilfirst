require 'rails_helper'

RSpec.describe Faculty, type: :model do
  describe '.valid_categories' do
    it 'returns valid categories' do
      categories = Faculty.valid_categories
      expect(categories.count).to eq(3)
      expect(categories - [Faculty::CATEGORY_TEAM, Faculty::CATEGORY_ADVISORY_BOARD, Faculty::CATEGORY_VISITING_FACULTY]).to be_empty
    end
  end
end
