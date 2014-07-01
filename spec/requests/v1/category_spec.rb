require 'spec_helper'

describe 'Category Requests' do
  include V1ApiSpecHelper

  describe 'GET /api/categories' do
    before do
      3.times { create :news_category }
      2.times { create :event_category }
    end

    context 'when no category type is specified' do
      it 'retrieves all categories' do
        get '/api/categories', {}, version_header
        expect(parse_json(response.body).count).to eq 5
      end
    end

    context 'when category type is specified' do
      it 'retrieves categories of specified category type' do
        get '/api/categories', { category_type: 'news' }, version_header
        expect(parse_json(response.body).count).to eq 3
      end
    end

    it 'contains id, name and category_type' do
      get '/api/categories', {}, version_header
      category = parse_json(response.body, '0')
      expect(category['id']).to_not be_nil
      expect(category['name']).to_not be_nil
      expect(category['category_type']).to_not be_nil
    end
  end
end
