class GraphqlController < ApplicationController
  skip_forgery_protection if: :skip_csrf_protection?
  skip_before_action :redirect_to_primary_domain, if: :introspection?

  def execute
    variables = ensure_hash(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]

    context = {
      pundit_user: pundit_user,
      current_school: current_school,
      current_user: current_user,
      current_school_admin: current_school_admin,
      session: session,
      notifications: [],
      token_auth: api_token.present?
    }

    result = PupilfirstSchema.execute(query, variables: variables, context: context, operation_name: operation_name)

    # Inject notifications into the GraphQL response, if any. These should be manually handled by the client.
    result[:notifications] = context[:notifications] if context[:notifications].any?

    render json: result
  rescue => e
    raise e unless Rails.env.development?

    handle_error_in_development e
  end

  private

  def introspection?
    Rails.env.development? && params[:introspection] == 'true'
  end

  def skip_csrf_protection?
    introspection? || (api_token.present? && current_user.present?)
  end

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: { error: { message: error.message, backtrace: error.backtrace }, data: {} }, status: :internal_server_error
  end
end
