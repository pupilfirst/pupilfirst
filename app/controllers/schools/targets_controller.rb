module Schools
  class TargetsController < SchoolsController
    before_action :load_new_target, only: %w[new create]
    before_action :load_target, only: %w[edit update]

    # POST /school/target_groups/:target_group_id/targets(.:format)
    def create
      # authorize(Target, policy_class: Schools::TargetPolicy)
      form = ::Schools::Targets::CreateForm.new(@target)
      if form.validate(params)
        form.save
        redirect_to school_course_curriculum_path(@target.course)
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    # GET /school/target_groups/:target_group_id/targets
    def new; end

    # GET /school/targets/:id/edit
    def edit; end

    # PATCH /school/targets/:id
    def update
      form = ::Schools::Targets::UpdateForm.new(@target)

      if form.validate(params[:target])
        form.save
        redirect_to school_course_curriculum_path(@target.course)
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    protected

    def load_new_target
      @target_group = TargetGroup.find(params[:target_group_id])
      @target = authorize(Target.new(target_group: @target_group), policy_class: Schools::TargetPolicy)
    end

    def load_target
      @target = authorize(Target.find(params[:id]), policy_class: Schools::TargetPolicy)
    end
  end
end
