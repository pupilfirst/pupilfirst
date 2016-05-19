class ApplicationFounder < ActiveRecord::Base
  belongs_to :batch_application

  validates :email, presence: true, uniqueness: true
  validate :email_must_look_right

  def email_must_look_right
    errors[:email] << "doesn't look like an email" unless email =~ /\S+@\S+/
  end

  has_secure_token
end
