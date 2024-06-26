class CreateAuthenticationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :authentication_tokens do |t|
      t.string :token, null: false
      t.references :authenticatable, polymorphic: true, index: false
      t.datetime :expires_at, null: false
      t.string :token_type, null: false
      t.integer :attempt_count, default: 0, null: false # Tracks the number of attempts
      t.timestamps
    end

    # Adding a composite index for better lookup performance and uniqueness validation.
    add_index(
      :authentication_tokens,
      %i[authenticatable_type authenticatable_id token_type token],
      unique: true,
      name: "index_auth_tokens_on_type_id_type_and_token"
    )

    # Index for quickly finding and cleaning up expired tokens.
    add_index :authentication_tokens, :expires_at
  end
end
