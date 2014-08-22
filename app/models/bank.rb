class Bank < ActiveRecord::Base
  belongs_to :startup

  def to_s
    ''
    #directors.map { |d| d.fullname }.join(',')
  end
end
