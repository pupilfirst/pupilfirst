module Schools
  class ResourcesController < SchoolsController
    # POST /school/resources
    def create
      authorize(Resource, policy_class: Schools::ResourcePolicy)
      form = ::Schools::Resources::CreateForm.new(Resource.new)
      if form.validate(params[:resource])
        resource = form.save(school_id)
        render json: { id: resource.id, error: nil }
      else
        raise form.errors.full_messages.join(', ')
      end
    end

    private

    def school_id
      current_school.id
    end
  end
end
