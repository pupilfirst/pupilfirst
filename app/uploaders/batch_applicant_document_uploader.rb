class BatchApplicantDocumentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::BombShelter

  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Resource files are private.
  def fog_public
    false
  end

  def fog_directory
    ENV['PRIVATE_S3_BUCKET_NAME']
  end

  version :thumb do
    process resize_to_limit: [100, 100]
  end
end
