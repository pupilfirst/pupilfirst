# encoding: utf-8

class IdentificationProofUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Uploaded file should fit within 1000x1000.
  process resize_to_limit: [1000, 1000]

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_limit: [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
