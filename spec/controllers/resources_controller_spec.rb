require 'rails_helper'

describe ResourcesController do
  let!(:binary_resource) { create :resource }
  let!(:video_resource) { create :video_resource }

  describe 'GET download' do
    it 'increments downloads of resource by 1' do
      expect do
        get :download, params: { id: binary_resource.id }
      end.to change { binary_resource.reload.downloads }.by(1)
    end
  end

  describe 'GET :id/show?watch=1' do
    it 'increments downloads of resource by 1' do
      expect do
        get :show, params: { id: video_resource.id, watch: true }
      end.to change { video_resource.reload.downloads }.by(1)
    end
  end
end
