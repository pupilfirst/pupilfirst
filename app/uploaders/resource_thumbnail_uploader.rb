# encoding: utf-8

class ResourceThumbnailUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}/thumbnails"
  end

  # Uploaded file should (ideally) be square.
  process resize_to_fill: [300, 300]

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
