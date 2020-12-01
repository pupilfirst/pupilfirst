class AddCoachingSessionCalendlyLinkToFaculty < ActiveRecord::Migration[6.0]
  def change
    add_column :faculty, :coaching_session_calendly_link, :string
  end
end
