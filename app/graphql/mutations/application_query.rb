module Mutations
  class ApplicationQuery < GraphQL::Schema::Mutation
    def resolve(params)
      @params = params
      if @context[:token_auth] && !allow_token_auth?
        raise UnavailableQueryException
      end
      execute
    end

    def respond_to_missing?(name, *args)
      context.key?(name.to_sym) || super
    end

    def method_missing(name, *args)
      name_symbol = name.to_sym
      context.key?(name_symbol) ? context[name_symbol] : super
    end

    def errors
      @errors ||= []
    end

    def error_messages
      errors.flatten
    end

    def notify(kind, title, body)
      context[:notifications].push(kind: kind, title: title, body: body)
    end

    def notify_errors
      notify(:error, 'Something went wrong!', error_messages.join(', '))
    end

    private

    def authorized?(*)
      raise 'Please implement the "authorized?" method in the query class.'
    end

    def allow_token_auth?
      false
    end
  end
end
