require 'fog/aws'

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required unless using use_iam_profile
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],                        # required unless using use_iam_profile
    use_iam_profile:       true,                         # optional, defaults to false
    region:                'us-west-1',                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['S3_BUCKET']                                      # required
  config.fog_public     = false                                                 # optional, defaults to true
end