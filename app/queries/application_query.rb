class ApplicationQuery
  include ActiveModel::Model

  attr_reader :context

  def initialize(context, attributes = {})
    @context = context
    assign_attributes(attributes)
    raise UnauthorizedQueryException unless authorized?
  end

  def respond_to_missing?(name, *args)
    context.key?(name.to_sym) || super
  end

  def method_missing(name, *args)
    name_symbol = name.to_sym
    super unless context.key?(name_symbol)

    context[name_symbol]
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
end
