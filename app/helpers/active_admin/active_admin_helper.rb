module ActiveAdmin
  module ActiveAdminHelper
    # Returns links to tags separated by a separator string.
    def linked_tags(tags, separator: ', ')
      return if tags.blank?

      tags.map do |tag|
        link_to tag.name, admin_tag_path(tag)
      end.join(separator).html_safe
    end

    # Return a string explaining details of reaction received on public slack
    def reaction_details(message)
      reaction_to_author = message.reaction_to.founder.present? ? message.reaction_to.founder.fullname : message.reaction_to.slack_username
      "reacted with #{message.body} to \'#{truncate(message.reaction_to.body, length: 250)}\' from #{reaction_to_author}"
    end

    def commitment_options
      {
        'Part Time' => Faculty::COMMITMENT_PART_TIME,
        'Full Time' => Faculty::COMMITMENT_FULL_TIME
      }
    end

    def none_one_or_many(view, resources)
      # .blank? is used to preload the list.
      return if resources.blank?

      if resources.size > 1
        view.ul do
          resources.each do |resource|
            view.li do
              yield(resource)
            end
          end
        end
      else
        yield(resources.first)
      end
    end
  end
end
