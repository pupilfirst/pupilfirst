ActiveAdmin.register Contact do
  remove_filter :versions

  controller do
    newrelic_ignore
  end

  permit_params :name, :mobile, :email, :designation, :company
end
