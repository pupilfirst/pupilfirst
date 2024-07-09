class SetupOneTimePasswordTables < ActiveRecord::Migration[7.0]
  def change
    # Create a table to store different kinds of tokens - OTP, sign in, password reset, etc.
    create_table :authentication_tokens do |t|
      t.string :token, null: false
      t.string :token_type, null: false
      t.string :purpose, null: false
      t.references :authenticatable, polymorphic: true, index: false
      t.datetime :expires_at, null: true
      t.timestamps
    end

    # Adding a composite index for better lookup performance and uniqueness validation.
    add_index(
      :authentication_tokens,
      %i[authenticatable_type authenticatable_id token],
      unique: true,
      name: "index_auth_tokens_on_type_id_and_token"
    )

    # Index for quickly finding and cleaning up expired tokens.
    add_index :authentication_tokens, :expires_at

    # Create a table to keep track of failed input token attempts.
    create_table :failed_input_token_attempts do |t|
      t.references :authenticatable, polymorphic: true, null: false
      t.string :purpose, null: false
      t.timestamps
    end

    add_index(
      :failed_input_token_attempts,
      %i[authenticatable_type authenticatable_id purpose],
      name: "index_failed_attempts_on_authenticatable_and_purpose"
    )

    # TODO: Considerations for removing old columns should be carefully reviewed.
    # remove_column :users, :login_token, :string
    # remove_column :users, :login_token_generated_at, :datetime
    # remove_column :users, :login_token_digest, :string
  end
end
