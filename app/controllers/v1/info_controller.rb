class V1::InfoController < V1::BaseController

	def mentors
    respond_to do |format|
        format.json
    end
	end

	def advisory_council
    respond_to do |format|
        format.json
    end
	end

end
