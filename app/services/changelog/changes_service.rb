module Changelog
  # Returns changelog entries grouped by week.
  class ChangesService
    CATEGORY_MAP = {
      'feature' => 'Features',
      'ui' => 'UI and UX',
      'performance' => 'Performance',
      'content' => 'Content',
      'bugfix' => 'Bugfixes'
    }.freeze

    # @param show_private [TrueClass, FalseClass] Set to true to show private changelog entries.
    def initialize(year, show_private)
      @year = year
      @show_private = show_private
    end

    # @return [Array] Array of changelog entries grouped by week. See method documentation for details.
    #
    # Returns:
    #
    # [
    #   {
    #     week_title: 'week start date',
    #     categories: {
    #       "Features": [
    #         {
    #           title: 'change',
    #           description: 'optional description for change',
    #           trello: OPTIONAL_TRELLO_LINK_STRING_OR_ARRAY
    #         }, ...
    #       ], ...
    #     }
    #   },
    # ]
    def releases
      changelogs = YAML.safe_load(File.read(Rails.root.join('changelog', "#{@year}.yaml")))['changelog']

      all_releases = changelogs.map do |release|
        {
          week_title: Time.parse(release['timestamp']).strftime('%b %d, %Y'),
          categories: categorized_entries(release)
        }
      end

      remove_empty_releases(all_releases)
    end

    private

    def remove_empty_releases(releases)
      releases.reject { |release| release[:categories].empty? }
    end

    def hash_category(recorded_category)
      CATEGORY_MAP[recorded_category] || 'Miscellaneous'
    end

    def categorized_entries(release)
      changes = release['changes'].each_with_object(template) do |change, hash|
        next if change['private'] && !@show_private

        entry = { title: change['title'], private: change['private'] }

        if @show_private
          entry[:description] = change['description'] if change['description'].present?
          entry[:trello] = [change['trello']].flatten if change['trello'].present?
        end

        hash[hash_category(change['category'])] << entry
      end

      remove_empty_categories(changes)
    end

    def remove_empty_categories(changes)
      changes.each_key { |key| changes.delete(key) if changes[key].blank? }
    end

    def template
      {
        'Features' => [],
        'UI and UX' => [],
        'Performance' => [],
        'Content' => [],
        'Bugfixes' => [],
        'Miscellaneous' => []
      }
    end
  end
end
