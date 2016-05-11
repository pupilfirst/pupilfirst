ActiveAdmin.register Glossary do
  menu parent: 'Dashboard', label: 'Glossary'
  index title: 'Glossary'
  permit_params :term, :definition, :links
end
