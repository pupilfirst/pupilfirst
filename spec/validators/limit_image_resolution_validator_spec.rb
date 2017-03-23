require 'rails_helper'

class LimitImageResolutionValidatorMock
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :avatar

  validates :avatar, limit_image_resolution: true
end

describe LimitImageResolutionValidator do
  subject { LimitImageResolutionValidatorMock.new(avatar: image_file) }

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
