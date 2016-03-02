module ActiveAdmin
  module ResourcesHelper
    def linked_tags(tags, separator: ', ')
      return unless tags.present?

      tags.map do |tag|
        link_to tag.name, admin_tag_path(tag)
      end.join(separator).html_safe
    end
  end
end
