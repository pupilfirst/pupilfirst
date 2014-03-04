class V1::EventsController < V1::BaseController
  skip_before_filter :require_token, only: [:index, :show]

	def index
    @events = Event.where('date(end_at) >= date(?)', Time.now).order('start_at asc').limit(50)
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
