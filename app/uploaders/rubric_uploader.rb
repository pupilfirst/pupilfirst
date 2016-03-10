# encoding: utf-8

class RubricUploader < CarrierWave::Uploader::Base
  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # TODO: Should we make the rubric public instead?
  def fog_public
    false
  end

  def fog_directory
    ENV['PRIVATE_S3_BUCKET_NAME']
  end
end
