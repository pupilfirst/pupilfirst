ActiveAdmin.register PerformanceCriterion do
  include DisableIntercom

  menu parent: 'Targets'

  permit_params :description
end
