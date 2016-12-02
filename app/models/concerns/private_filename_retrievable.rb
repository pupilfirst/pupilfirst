# This allows models to safely retrieve the filename of files stored in private buckets.
module PrivateFilenameRetrievable
  extend ActiveSupport::Concern

  # Carrierwave method .original_filename isn't reliably available on the sanitized file return. Reason for this is
  # unknown - so this method call is set to return 'existing file' if that call fails.
  def filename(field)
    public_send(field)&.sanitized_file&.original_filename || 'existing file'
  end
end
