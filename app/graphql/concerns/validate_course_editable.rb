module ValidateCourseEditable
  extend ActiveSupport::Concern

  class LimitedProgressionRequiresDetails < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      unless value[:progression_behavior] ==
               Course::PROGRESSION_BEHAVIOR_LIMITED
        return
      end

      if value[:progression_limit].blank?
        return(
          'Progression limit must be specified when the course progression is limited'
        )
      end
    end
  end

  class ValidProcessingURL < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      return if value[:processing_url].blank?

      begin
        uri = URI.parse(value[:processing_url])
        resp = uri.kind_of?(URI::HTTP)
      rescue URI::InvalidURIError
        resp = false
      end

      return 'Processing url must be valid' unless resp == true
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
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :about,
             GraphQL::Types::String,
             required: false,
             validates: {
               length: {
                 maximum: 10_000
               }
             }

    argument :progression_behavior,
             Types::ProgressionBehaviorType,
             required: true,
             validates: {
               inclusion: {
                 in: Course::VALID_PROGRESSION_BEHAVIORS
               }
             }
    argument :progression_limit,
             GraphQL::Types::Int,
             required: false,
             validates: {
               numericality: {
                 greater_than_or_equal_to: 1,
                 less_than_or_equal_to: 3
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

    validates LimitedProgressionRequiresDetails => {}
    validates ValidProcessingURL => {}
  end

  def sanitized_progression_limit
    if @params[:progression_behavior] == Course::PROGRESSION_BEHAVIOR_LIMITED
      @params[:progression_limit]
    else
      nil
    end
  end

  def course_data
    {
      name: @params[:name],
      description: @params[:description],
      ends_at: @params[:ends_at],
      public_signup: @params[:public_signup],
      public_preview: @params[:public_preview],
      about: @params[:about],
      featured: @params[:featured],
      progression_behavior: @params[:progression_behavior],
      progression_limit: sanitized_progression_limit,
      highlights: @params[:highlights].presence || [],
      processing_url: @params[:processing_url]
    }
  end
end
