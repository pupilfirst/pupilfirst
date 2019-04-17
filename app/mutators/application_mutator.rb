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
    authorize
    super
  end

  def authorize
    raise 'Please implement the "authorize" method in the mutator class.'
  end
end
