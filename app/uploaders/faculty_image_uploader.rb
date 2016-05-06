# encoding: utf-8

class FacultyImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Uploaded file should be of aspect ratio 0.833. Display size is 200x240.
  process resize_to_fill: [300, 360]

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
