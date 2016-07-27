module DisableIntercom
  extend ActiveSupport::Concern

  def self.included(base)
    base.send :skip_after_action, :intercom_rails_auto_include
  end
end
