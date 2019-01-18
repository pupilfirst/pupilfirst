module Schools
  class ResourcesController < SchoolsController
    # POST /school/resources
    def create
      authorize(Resource, policy_class: Schools::TargetGroupPolicy)
      form = ::Schools::Resources::CreateForm.new(Resource.new)
      if form.validate(params[:resource])
        form.save
        redirect_back(fallback_location: school_path)
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    private

    def course
      Level.find(params[:level_id]).course
    end

    def target_group
      @target_group = authorize(TargetGroup.find(params[:id]), policy_class: Schools::TargetGroupPolicy)
    end
  end
end
