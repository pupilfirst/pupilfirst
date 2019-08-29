module Schools
  class TargetsController < SchoolsController
    before_action :load_target, only: %w[update]

    # PATCH /school/targets/:id
    def update
      form = ::Schools::Targets::UpdateForm.new(@target)

      if form.validate(params[:target])
        form.save
        render json: { error: nil }
      else
        render json: { error: form.errors.full_messages.join(', ') }
      end
    end

    # GET /school/targets/:id/content
    def content
      render json: camelize_keys(stringify_ids(Targets::FetchContentService.new(@target).details))
    end

    protected

    def load_target
      @target = authorize(Target.find(params[:id]), policy_class: Schools::TargetPolicy)
    end
  end
end
