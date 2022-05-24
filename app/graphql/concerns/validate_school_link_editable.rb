module ValidateSchoolLinkEditable
  extend ActiveSupport::Concern
  included do
    argument :id, GraphQL::Types::ID, required: true

    argument :url, GraphQL::Types::String, required: false

    argument :title,
             GraphQL::Types::String,
             required: false,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 24,
                 message: 'Invalid Title'
               }
             }
  end

  def school_link_data
    { id: @params[:id], title: @params[:title], url: @params[:url] }
  end
end
