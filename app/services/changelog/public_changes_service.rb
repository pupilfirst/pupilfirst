module Changelog
  # What does this class do?
  class PublicChangesService
    CATEGORY_MAP = {
      'feature' => 'Features',
      'ui' => 'UI and UX',
      'performance' => 'Performance',
      'content' => 'Content',
      'bugfix' => 'Bugfixes'
    }.freeze

    # Returns:
    #
    # [
    #   {
    #     week_title: 'week start date',
    #     categories: {
    #       "Features": [
    #         "change 1",
    #         "change 2", ...
    #       ], ...
    #     }
    #   },
    # ]
    def releases
      changelogs = YAML.safe_load(File.read(Rails.root.join('changelog', '2017.yaml')))['changelog']

      changelogs.map do |release|
        {
          week_title: Time.parse(release['timestamp']).strftime('%b %d, %Y'),
          categories: categorized_entries(release)
        }
      end
    end

    private

    def categorized_entries(release)
      changes = release['changes'].each_with_object(template) do |change, hash|
        next if change['private']
        hash[CATEGORY_MAP[change['category']] || 'Miscellaneous'] << change['title']
      end

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
