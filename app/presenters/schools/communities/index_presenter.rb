module Schools
  module Communities
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, school)
        super(view_context)

        @school = school
      end

      def react_props
        {
          authenticityToken: view.form_authenticity_token,
          communities: communities,
          courses: courses
        }.to_json
      end

      def communities
        @school.communities.map do |community|
          {
            id: community.id.to_s,
            name: community.name
          }
        end
      end

      def courses
        @school.courses.map do |course|
          {
            id: course.id.to_s,
            name: course.name,
            communityId: course.community_id.present? ? course.community_id.to_s : nil
          }
        end
      end
    end
  end
end
