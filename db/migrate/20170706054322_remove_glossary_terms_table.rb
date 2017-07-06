class RemoveGlossaryTermsTable < ActiveRecord::Migration[5.1]
  def up
    drop_table :glossary_terms
  end

  def down
    create_table 'glossary_terms', id: :serial, force: :cascade do |t|
      t.string 'term'
      t.text 'definition'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
    end
  end
end
