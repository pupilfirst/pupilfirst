require 'rails_helper'

describe ResourcesController do
  let!(:binary_resource) { create :resource }
  let!(:video_resource) { create :video_resource }

  describe 'GET generate_download_url' do
    it 'increments downloads of resource by 1' do
      downloads = binary_resource.downloads

      get :generate_download_url, id: binary_resource.id
      binary_resource.reload
      new_downloads = binary_resource.downloads

      expect(new_downloads).to eq(downloads + 1)
    end
  end

  describe 'GET :id/show?watch=1' do
    it 'increments downloads of resource by 1' do
      downloads = video_resource.downloads

      get :show, id: video_resource.id, watch: true
      video_resource.reload
      new_downloads = video_resource.downloads

      expect(new_downloads).to eq(downloads + 1)
    end
  end
end
