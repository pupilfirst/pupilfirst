module Schools
  module Communities
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, school)
        super(view_context)

        @school = school
      end

      def props
        {
          communities: communities,
          courses: courses,
        }
      end

      def communities
        @communities ||=
          @school.communities.map do |community|
            {
              id: community.id.to_s,
              name: community.name,
              target_linkable: community.target_linkable,
              topic_categories: topic_categories(community),
              course_ids:  community.course_ids.map(&:to_s)
            }
          end
      end

      def courses
        @school.courses.map do |course|
          {
            id: course.id.to_s,
            name: course.name
          }
        end
      end

      def topic_categories(community)
        topic_categories = ActiveRecord::Precounter.new(TopicCategory.where(community: community)).precount(:topics)
        topic_categories.map { |category| category.attributes.slice('id', 'name', 'community_id').merge({ topics_count: category.topics_count }) }
      end
    end
  end
end
