class RenameKeyTermsOfUseToTermsAndConditions < ActiveRecord::Migration[6.0]
  class SchoolString < ApplicationRecord
  end

  def up
    SchoolString.where(key: 'terms_of_use').update_all(key: 'terms_and_conditions')
  end

  def down
    SchoolString.where(key: 'terms_and_conditions').update_all(key: 'terms_of_use')
  end
end
