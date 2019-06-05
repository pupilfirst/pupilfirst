module Schools
  class CommunitiesController < SchoolsController
    def index
      @school = authorize(current_school, policy_class: Schools::CommunityPolicy)
      render layout: 'school'
    end
  end
end
