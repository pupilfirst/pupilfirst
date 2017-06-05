class ChangelogController < ApplicationController
  layout 'application_v2'

  # GET /changelog
  def index
    @skip_container = true
    @changelog_releases = Changelog::PublicChangesService.new.releases
  end

  # GET /changelog/archive
  def archive
    @skip_container = true
    @changelog = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
  end
end
