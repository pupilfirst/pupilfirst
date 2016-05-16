class GlossaryTerm < ActiveRecord::Base
  validates_presence_of :term, :definition

  before_save do
    self.term = term.downcase
  end
end
