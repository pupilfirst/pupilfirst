class Partnership < ActiveRecord::Base
  belongs_to :user
  belongs_to :startup

  validates_presence_of :user_id
  validates_presence_of :startup_id
  validates_presence_of :shares
  validates_presence_of :salary
  validates_presence_of :cash_contribution

  validates_uniqueness_of :user_id, scope: :startup_id

  # Sends a confirmation email to partner (someone who could be a founder).
  def send_confirmation_email(startup, requesting_user)
    # Don't send confirmation mail for requesting user.
    return if requesting_user == self.user

    generate_confirmation_token!

    # TODO: Defer mailing of partnership confirmation email.
    UserMailer.confirm_partnership_formation(self, requesting_user).deliver
  end

  # Generate a confirmation_token which allows visitor to edit user fields and set partnership as confirmed.
  def generate_confirmation_token!
    update! confirmation_token: SecureRandom.urlsafe_base64
  end

  # Set the partnership as confirmed, by setting confirmed_at and wiping confirmation_token.
  def confirm!
    update! confirmed_at: Time.now, confirmation_token: nil
  end
end
