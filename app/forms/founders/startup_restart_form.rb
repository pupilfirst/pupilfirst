module Founders
  class StartupRestartForm < Reform::Form
    property :level_id, virtual: true, validates: { presence: true }
    property :reason, virtual: true, validates: { presence: true }
  end
end
