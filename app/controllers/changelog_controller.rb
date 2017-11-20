class ChangelogController < ApplicationController
  # GET /changelog
  def index
    @skip_container = true
    @changelog_releases = Changelog::ChangesService.new(current_user&.admin_user.present?).releases
  end

  # GET /changelog/archive
  def archive
    @skip_container = true
    @changelog = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
  end
end
