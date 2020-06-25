module Schools
  class ConfigurationPresenter < ApplicationPresenter
    def props
      view.current_school.configuration.merge(school_name: current_school.name)
    end
  end
end
