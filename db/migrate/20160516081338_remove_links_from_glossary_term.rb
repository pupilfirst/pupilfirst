class RemoveLinksFromGlossaryTerm < ActiveRecord::Migration[4.2]
  def change
    remove_column :glossary_terms, :links, :text
  end
end
