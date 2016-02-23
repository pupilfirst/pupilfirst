# encoding: utf-8

class StartupFeedbackAttachmentUploader < CarrierWave::Uploader::Base
  # Override the directory where uploaded files will be stored.
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Timeline event files are private.
  def fog_public
    false
  end
end
