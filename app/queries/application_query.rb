class ApplicationQuery
  include ActiveModel::Model

  attr_reader :context

  def self.property(name, options = {})
    attr_accessor name
    validates(name, options[:validates]) if options.key?(:validates)
  end

  def initialize(context, attributes = {})
    @context = context
    assign_attributes(attributes)

    raise UnavailableQueryException if @context[:token_auth] && !allow_token_auth?
    raise UnauthorizedQueryException unless authorized?
  end

  def respond_to_missing?(name, *args)
    context.key?(name.to_sym) || super
  end

  def method_missing(name, *args)
    name_symbol = name.to_sym
    context.key?(name_symbol) ? context[name_symbol] : super
  end

  def error_messages
    errors.messages.values.flatten
  end

  def notify(kind, title, body)
    context[:notifications].push(kind: kind, title: title, body: body)
  end

  def notify_errors
    notify(:error, 'Something went wrong!', error_messages.join(", "))
  end

  private

  def authorized?
    raise 'Please implement the "authorized?" method in the query class.'
  end

  def allow_token_auth?
    false
  end
end
