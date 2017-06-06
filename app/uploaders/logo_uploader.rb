# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::Backgrounder::Delay
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  # Choose what kind of storage to use for this uploader:
  # storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Uploaded file shouldn't be greater than 500x500
  process resize_to_limit: [500, 500]

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
end
