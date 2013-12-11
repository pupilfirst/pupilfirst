class V1::EventsController < V1::BaseController

	def index
    @events = Event.where('date(start_at) >= date(?)', Time.now).order('start_at desc').limit(50)
    @events = @events.select{|e| e.featured } + @events.reject{|e| e.featured }
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
