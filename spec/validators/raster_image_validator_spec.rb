require 'rails_helper'

class RasterImageValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :avatar

  validates :avatar, raster_image: true
end

describe RasterImageValidator do
  subject { RasterImageValidatorMock.new(avatar: image_file) }

  context 'when file is not an image' do
    let(:image_file) do
      Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))
    end

    it { is_expected.to_not be_valid }
  end

  context 'when file is an image' do
    context 'when image is of acceptable size' do
      let(:image_file) do
        Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'donald_duck.jpg'))
      end

      it { is_expected.to be_valid }
    end

    context 'when image is unacceptably large' do
      let(:image_file) do
        Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'files', 'high_resolution.png'))
      end

      it { is_expected.to_not be_valid }
    end
  end
end
