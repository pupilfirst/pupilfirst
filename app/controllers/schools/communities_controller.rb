module Schools
  class CommunitiesController < SchoolsController
    def index
      @school = authorize(current_school, policy_class: Schools::CommunityPolicy)
      if !Feature.active?('communities', current_user)
        redirect_to root_path
      else
        render layout: 'school'
      end
    end
  end
end
