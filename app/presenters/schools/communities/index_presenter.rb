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
          connections: connections,
          categories: categories
        }
      end

      def communities
        @communities ||=
          @school.communities.map do |community|
            {
              id: community.id.to_s,
              name: community.name,
              targetLinkable: community.target_linkable
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

      def connections
        CommunityCourseConnection.where(community: communities.pluck(:id)).map do |connection|
          {
            communityId: connection.community_id.to_s,
            courseId: connection.course_id.to_s
          }
        end
      end

      def categories
        CommunityTopicCategory.where(community: @school.communities).map { |category| category.attributes.slice('id', 'name', 'community_id') }
      end
    end
  end
end
