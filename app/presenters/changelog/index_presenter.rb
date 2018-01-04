module Changelog
  class IndexPresenter < ApplicationPresenter
    def initialize(view_context, year)
      @year = year
      super(view_context)
    end

    def forward_link
      return nil if @year == Time.now.year
      nav_link(@year + 1)
    end

    def reverse_link
      return nav_link('archive', text: 'View Changelog Archive', link: view.changelog_archive_path) if @year == 2017
      nav_link(@year - 1)
    end

    private

    def nav_link(year, text: "Changelog for #{year}", link: view.changelog_path(year: year))
      direction = year == 'archive' || year < @year ? :left : :right
      icon_class =  direction == :left ? 'fa-angle-double-left' : 'fa-angle-double-right'
      icon_markup = "<i class='fa #{icon_class}'></i>"
      link_text = direction == :left ? "#{icon_markup}&nbsp;&nbsp;#{text}" : "#{text}&nbsp;&nbsp;#{icon_markup}"

      view.link_to(link, class: 'btn btn-primary btn-md') do
        link_text.html_safe
      end
    end
  end
end
