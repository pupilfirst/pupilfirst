class TransactionalService
  def initialize(service)
    @service = service
  end

  def execute(...)
    ApplicationRecord.transaction do
      @service.execute(...)
    end
  end
end