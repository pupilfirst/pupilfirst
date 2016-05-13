class RenameGlossaryToGlossaryTerm < ActiveRecord::Migration
  def change
    rename_table :glossaries, :glossary_terms
  end
end
