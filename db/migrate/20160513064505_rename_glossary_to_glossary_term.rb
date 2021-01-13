class RenameGlossaryToGlossaryTerm < ActiveRecord::Migration[4.2]
  def change
    rename_table :glossaries, :glossary_terms
  end
end
