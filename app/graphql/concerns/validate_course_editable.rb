module ValidateCourseEditable
  extend ActiveSupport::Concern

  class ValidProcessingURL < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      return if value[:processing_url].blank?

      begin
        uri = URI.parse(value[:processing_url])
        resp = uri.kind_of?(URI::HTTP)
      rescue URI::InvalidURIError
        resp = false
      end

      return "Processing url must be valid" unless resp == true
    end
  end

  included do
    argument :name,
             GraphQL::Types::String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 50
               }
             }
    argument :description,
             GraphQL::Types::String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 150
               }
             }
    argument :about,
             GraphQL::Types::String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }
    argument :progression_limit,
             GraphQL::Types::Int,
             required: true,
             validates: {
               numericality: {
                 greater_than_or_equal_to: 0,
                 less_than_or_equal_to: 4
               }
             }
    argument :highlights,
             [Types::CourseHighlightInputType],
             required: false,
             validates: {
               length: {
                 maximum: 4
               }
             }
    argument :public_signup, GraphQL::Types::Boolean, required: true
    argument :public_preview, GraphQL::Types::Boolean, required: true
    argument :featured, GraphQL::Types::Boolean, required: true
    argument :processing_url, GraphQL::Types::String, required: false

    validates ValidProcessingURL => {}
  end

  def course_data
    {
      name: @params[:name],
      description: @params[:description],
      public_signup: @params[:public_signup],
      public_preview: @params[:public_preview],
      about: @params[:about],
      featured: @params[:featured],
      progression_limit: @params[:progression_limit],
      highlights: @params[:highlights].presence || [],
      processing_url: @params[:processing_url],
      default_cohort_id: @params[:default_cohort_id]
    }
  end
end
