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
  end
end
