require 'rails_helper'

describe ResourcesController do
  let!(:binary_resource) { create :resource }
  let!(:video_resource) { create :video_resource }

  before :all do
    PublicSlackTalk.mock = true
  end

  after :all do
    PublicSlackTalk.mock = false
  end

  describe 'GET download' do
    it 'increments downloads of resource by 1' do
      downloads = binary_resource.downloads

      get :download, id: binary_resource.id
      binary_resource.reload

      expect(binary_resource.downloads).to eq(downloads + 1)
    end
  end

  describe 'GET :id/show?watch=1' do
    it 'increments downloads of resource by 1' do
      downloads = video_resource.downloads

      get :show, id: video_resource.id, watch: true
      video_resource.reload

      expect(video_resource.downloads).to eq(downloads + 1)
    end
  end
end
