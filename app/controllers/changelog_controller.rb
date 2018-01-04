class ChangelogController < ApplicationController
  # GET /changelog
  def index
    @year = changelog_year
    @skip_container = true
    @changelog_releases = Changelog::ChangesService.new(@year, current_user&.admin_user.present?).releases
  end

  # GET /changelog/archive
  def archive
    @skip_container = true
    @changelog = File.read(File.absolute_path(Rails.root.join('CHANGELOG.md')))
  end

  private

  def changelog_year
    case params[:year]
      when '2018', '2017'
        params[:year].to_i
      else
        2018
    end
  end
end
