class V1::EventsController < V1::BaseController

	def index
    @events = Event.last(50).sort_by {|n| n.featured ? 1 : 2}
    respond_to do |format|
        format.json
    end
	end


	def show
		@event = Event.find(params[:id])
		respond_to do |f|
			f.json
		end
	end
end
