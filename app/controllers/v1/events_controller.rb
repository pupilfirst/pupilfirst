class V1::EventsController < V1::BaseController

	def index
    @events = Event.all
    respond_to do |format|
        format.json
    end
	end
end
