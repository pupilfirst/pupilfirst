ActiveAdmin.register GlossaryTerm do
  menu parent: 'Dashboard', label: 'Glossary'

  permit_params :term, :definition, :links

  index title: 'Glossary' do
    selectable_column

    column :term
    column :definition
    actions
  end
end
