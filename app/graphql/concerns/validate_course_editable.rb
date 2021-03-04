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
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 50
               }
             }
    argument :description,
             String,
             required: true,
             validates: {
               length: {
                 minimum: 1,
                 maximum: 150
               }
             }
    argument :ends_at, GraphQL::Types::ISO8601DateTime, required: false
    argument :about,
             String,
             required: true,
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
             Integer,
             required: false,
             validates: {
               numericality: {
                 greater_than_or_equal_to: 1,
                 less_than_or_equal_to: 3
               }
             }
    argument :highlights, [Types::CourseHighlightInputType], required: true
    argument :processing_url, String, required: false

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
      about: @params[:about],
      featured: @params[:featured],
      progression_behavior: @params[:progression_behavior],
      progression_limit: sanitized_progression_limit,
      highlights: @params[:highlights],
      processing_url: @params[:processing_ur]
    }
  end
end
