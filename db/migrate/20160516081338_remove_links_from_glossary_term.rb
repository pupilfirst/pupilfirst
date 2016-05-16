class RemoveLinksFromGlossaryTerm < ActiveRecord::Migration
  def change
    remove_column :glossary_terms, :links, :text
  end
end
