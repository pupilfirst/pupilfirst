CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS', # required
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], # required
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], # required
      region: ENV['S3_REGION'], # optional, defaults to 'us-east-1'
      host: 's3.amazonaws.com', # optional, defaults to nil
      # endpoint: 'https://s3.example.com:8080/'           # optional, defaults to nil
      path_style: true
    }

    config.fog_public = true # optional, defaults to true
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' } # optional, defaults to {}
    config.cache_dir = "#{Rails.root}/tmp/uploads" # To let CarrierWave work on heroku
    config.fog_directory = ENV['S3_BUCKET_NAME'] || "svapp-#{Rails.env}"
    # config.asset_host       = "https://#{ENV["S3_BUCKET_NAME"]}.s3.amazonaws.com/#{ENV['S3_BUCKET_NAME']}"
    config.asset_host = ENV['ASSET_HOST']
  elsif Rails.env.test?
    config.storage = :file
    config.enable_processing = false
  else
    # For testing, upload files to local `tmp` folder.
    config.storage = :file
    config.root = "#{Rails.root}/public"
  end
end
