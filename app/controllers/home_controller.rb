class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:csp_report]

  def index
    @featured_startups = Startup.where(featured: true)
    @navbar_start_transparent = true
    @skip_container = true
  end

  def faculty
    raise_not_found unless feature_active? :faculty_page
    
    @faculty = {
      advisory_board: [
        { name: "Kris Gopalakrishnan", title: "Chief Mentor, Co-Founder Infosys" },
        { name: "Kiran Karnik", title: "Board Member, Reserve Bank of India" },
        { name: "Dr. H.K. Mittal", title: "Head, NSTEDB, Department of Science and Technology, Government of India" },
        { name: "Rajan Mathews", title: "Director Generator, Cellular Operators Association of India" },
        { name: "Annie Mathew", title: "Research in Motion" },
        { name: "Murali Gopalan", title: "Charter Member, TIE" },
        { name: "R.K. Nair", title: "Ex CEO, Technopark" },
        { name: "Dr. K.C.C. Nair", title: "Ex CFO, Technopark" },
        { name: "Dr. Jayasankar Prasad", title: "CEO, Kerala Startup Mission" },
        { name: "K.T. Rajagopalan", title: "Ex Director, State Bank of Travancore" },
        { name: "Dr. B. Anil", title: "Principal, Government Engineering College,Barton Hill" }
      ]
    }

    @skip_container = true
  end

  def about
    raise_not_found unless feature_active? :about_page
  end

  def csp_report
    report = JSON.parse(request.body.read)
    Rails.llog.warn({ event: :csp_report }.merge(report['csp-report'].slice('blocked-uri', 'violated-directive', 'source-file')))
    Rails.llog.debug({ event: :full_csp_report }.merge(report))
    render nothing: true
  end
  
  private
  def image_name_from_faculty(type, image)
    "faculty/#{type}/". #Images are stored in a subfolder in faculty/
      +(image).
      gsub('Dr. ', ''). #Remove Salutations
      gsub('.', '_'). #Convert initials to underscores
      gsub(' ', '_'). #Convert spaces to underscores
      underscore. #Convert to underscore case
      gsub(/_+/, '_'). #Convert multiple underscores to one
      +(".png") #PNG image
  end 
  helper_method :image_name_from_faculty
  
end
