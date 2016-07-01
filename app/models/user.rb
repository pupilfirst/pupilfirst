class User < ActiveRecord::Base
  has_secure_token :login_token
  after_create :regenerate_login_token
end
