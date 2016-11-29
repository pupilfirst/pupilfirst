# This allows models to safely retrieve the filename of files stored in private buckets.
module PrivateFilenameRetrievable
  extend ActiveSupport::Concern

  def filename(field)
    public_send(field).sanitized_file.original_filename
  end
end
