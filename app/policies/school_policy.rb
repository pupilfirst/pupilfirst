class SchoolPolicy < ApplicationPolicy
  def show?
    return false if user.blank?

    user.school_admin.present?
  end

  alias customize? show?
  alias images? show?
  alias admins? show?
  alias school_router? show?
  alias standing? show?
  alias toggle_standing? show?
  alias code_of_conduct? show?
  alias update_code_of_conduct? show?
  alias discord_configuration? show?
  alias discord_server_roles? show?
  alias discord_credentials? show?
  alias discord_sync_roles? show?
  alias update_default_discord_roles? show?
  alias sync_confirmed_discord_roles? show?
end
