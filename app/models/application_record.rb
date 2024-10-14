class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  acts_as_copy_target
end
