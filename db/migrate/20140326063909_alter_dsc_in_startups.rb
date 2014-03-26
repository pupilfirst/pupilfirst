class AlterDscInStartups < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE startups ALTER dsc TYPE boolean USING CASE dsc WHEN 'Y' THEN TRUE ELSE FALSE END;"
  end

  def self.down
    execute "ALTER TABLE startups ALTER dsc TYPE varchar(255) USING CASE dsc
    WHEN TRUE THEN 'Y'
    WHEN FALSE THEN 'N' END;"
  end

end
