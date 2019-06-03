class ApplicationMutator
  include ActiveModel::Model

  attr_reader :context

  def initialize(attributes, context)
    @context = context
    assign_attributes(attributes)
  end

  def respond_to_missing?(name, *args)
    context.key?(name.to_sym) || super
  end

  def method_missing(name, *args)
    name_symbol = name.to_sym
    super unless context.key?(name_symbol)

    context[name_symbol]
  end

  def error_codes
    errors.messages.values.flatten
  end

  def valid?
    raise UnauthorizedMutationException unless authorized?

    super
  end

  def notify(kind, title, body)
    context[:notifications].push(kind: kind, title: title, body: body)
  end

  def notify_errors
    context[:notifications].push(kind: 'error', title: "Something went wrong!", body: error_codes.join(", "))
  end

  private

  def authorized?
    raise 'Please implement the "authorized?" method in the mutator class.'
  end
end
