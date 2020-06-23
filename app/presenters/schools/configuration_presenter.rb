module Schools
  class ConfigurationPresenter < ApplicationPresenter
    def props
      view.current_school.configuration
    end
  end
end
