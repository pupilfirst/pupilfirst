module Mutations
  class ApplicationQuery < GraphQL::Schema::Mutation
    def respond_to_missing?(name, *args)
      context.key?(name.to_sym) || super
    end

    def method_missing(name, *args)
      name_symbol = name.to_sym
      context.key?(name_symbol) ? context[name_symbol] : super
    end

    def notify(kind, title, body)
      context[:notifications].push(kind: kind, title: title, body: body)
    end

    def query_authorized?
      raise 'Please implement the "authorized?" method in the query class.'
    end

    def allow_token_auth?
      false
    end

    def authorized?(**params)
      @params = params

      if token_auth && !allow_token_auth?
        raise GraphQL::ExecutionError,
              'Authentication using a token is not allowed!'
      end

      return true if query_authorized?

      raise GraphQL::ExecutionError, 'Authorization failed'
    end
  end
end
