class StartupApplication < ActiveRecord::Base
	validates_presence_of :name
	validates_presence_of :email
	validates_presence_of :idea
	validates_presence_of :phone
end
