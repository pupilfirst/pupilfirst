class GlossaryTerm < ApplicationRecord
  validates :term, presence: true
  validates :definition, presence: true

  before_save do
    self.term = term.downcase
  end
end
