module Schools
  class ResourcesController < SchoolsController
    # POST /school/resources
    def create
      authorize(Resource, policy_class: Schools::ResourcePolicy)
      form = ::Schools::Resources::CreateForm.new(Resource.new)
      if form.validate(params[:resource])
        resource = form.save
        render json: { id: resource.id, errors: nil }
      else
        raise form.errors.full_messages.join(', ')
      end
    end
  end
end
