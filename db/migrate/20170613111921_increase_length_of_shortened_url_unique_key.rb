class IncreaseLengthOfShortenedUrlUniqueKey < ActiveRecord::Migration[5.1]
  def up
    change_column :shortened_urls, :unique_key, :string, limit: 100
  end

  def down
    change_column :shortened_urls, :unique_key, :string, limit: 10
  end
end
