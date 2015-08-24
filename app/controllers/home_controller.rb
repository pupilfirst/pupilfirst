class HomeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:csp_report]

  def index
    @featured_startups = Startup.where(featured: true)
    @navbar_start_transparent = true
    @skip_container = true
  end

  def faculty
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
        { name: "Dr. B. Anil", title: "Principal, Government Engineering College, Barton Hill" }
      ],
      visiting_faculty: [
        { name: "Abhishek Goyal", title: "Co-Founder, Traxcn Labs", key_skills: "Business Ideas", linked_in: "https://www.linkedin.com/in/abhishekgoyal" },
        { name: "Nishant Verman", title: "Director of Corporate Development, Flipkart", key_skills: "Acquisitions", linked_in: "https://in.linkedin.com/in/nishantverman" },
        { name: "Sharad Sharma", title: "Co-Founder, Ispirt", key_skills: "Angel Investments", linked_in: "https://www.linkedin.com/in/sharadsharma" },
        { name: "Karan Mohla", title: "Executive Director, IDG Ventures", key_skills: "Angel Investments", linked_in: "https://in.linkedin.com/pub/karan-mohla/0/998/153" },
        { name: "Sunil Kalra", title: "Professional Angel Investor", key_skills: "Angel Investments", linked_in: "https://www.linkedin.com/pub/sunil-kalra/21/9a6/a12" },
        { name: "Alok Bajpai", title: "Co-Founder IXIGO", key_skills: "Product Strategy", linked_in: "https://www.linkedin.com/in/alokebajpai" },
        { name: "Krishnakumar Natarajan", title: "Co-Founder Mindtree", key_skills: "Scaling up", linked_in: "https://www.linkedin.com/pub/krishnakumar-natarajan/0/338/839" },
        { name: "George Brody", title: "Founder, Globe Ranger", key_skills: "Product Strategy", linked_in: "https://www.linkedin.com/in/georgebrodyprofile" },
        { name: "Ganesh Lakshminarayan", title: "Consultant @ Sequoia Capital", key_skills: "Scaling up", linked_in: "https://www.linkedin.com/in/ganeshls" },
        { name: "Sasha Mirchandani", title: "Founder, Kae Capital", key_skills: "Angel Investments", linked_in: "https://www.linkedin.com/pub/sasha-mirchandani/13/489/81a" },
        { name: "Phanindra Sama", title: "Founder, Red Bus", key_skills: "Business Ideas", linked_in: "https://www.linkedin.com/pub/sasha-mirchandani/13/489/81a" },
        { name: "Nandakumar", title: "CEO, SunTec", key_skills: "Scaling up", linked_in: "https://in.linkedin.com/in/knandakumar" },
        { name: "Aakrit Vaish", title: "Co-Founder, Haptik", key_skills: "Product Strategy", linked_in: "https://www.linkedin.com/in/aakrit" },
        { name: "Ravi Kiran", title: "Co-Founder, Venture Nursery", key_skills: "Accelerating Startups", linked_in: "http://in.linkedin.com/in/ravitwo" },
        { name: "Shradha Sharma", title: "Founder, Yourstory", key_skills: "Public Relations", linked_in: "https://www.linkedin.com/in/sharmashradha" },
        { name: "Amit Gupta", title: "Co-Founder InMobi", key_skills: "Startup Revenues", linked_in: "https://www.linkedin.com/in/amitgupta007" },
        { name: "Freeman Murray", title: "Founder, Jaaga", key_skills: "Startup Prototyping", linked_in: "http://in.linkedin.com/in/freemanmurray" },
        { name: "Shashi Dharan", title: "Founder of BE Group", key_skills: "Public Relations", linked_in: "https://www.linkedin.com/pub/shashi-dharan/9/583/396" }
      ],
      team: [
        { name: "Sanjay Vijayakumar", title: "Chairman" },
        { name: "Pranav Suresh", title: "CEO" },
        { name: "Vishnu Gopal", title: "CTO" },
        { name: "Gautham", title: "COO" },
        { name: "Rohan Kalani", title: "AVP Operations & Finance"},
        { name: "Hari Gopal", title: "Engineering Architect"},
        { name: "Joby Joseph", title: "Product" },
        { name: "Naveen Narayanan", title: "Academic Relations" },
        { name: "Daniel Jeevan", title: "Digital Strategist" },
        { name: "Aditya Nair", title: "Governance & Strategic Initiatives" },
        { name: "Abdul Jaleel", title: "Software Engineer"},
        { name: "Sreerag Dileep", title: "Governance & Operations" },
        { name: "Dinnu Nijo", title: "Incubation" },
        { name: "Sebin John Mathew", title: "Communications & Operations" },
        { name: "Shameem P", title: "Client Relations"},
        { name: "Kiran Baby", title:	"Client Relations" },
        { name: "Manoj Krishnan", title: "Head, Startup Studio" },
        { name: "Varun M", title: "Academic & Client Relations" },
        { name: "Vasudeva Rao Thumati", title: "Operations"},
        { name: "Kireeti Varma", title: "Operations"},
        { name: "Bharat Pinnam", title: "Operations", linked_in: "https://in.linkedin.com/pub/pinnam-bharat/64/a6a/3a2" },
        { name: "Mini M", title: "Administration"},
        { name: "Shajahan Ibrahim", title: "Administration" }
      ]
    }

    @skip_container = true
  end

  def about
  end
  
  def transparency
  end
  
  def slack
  end
  
  def leaderboards
    if params[:year]
      @leaderboard_chunk = :"l#{params[:year]}_#{params[:month]}_#{params[:day]}"
      @leaderboard_partial = "home/leaderboards/#{@leaderboard_chunk}"
    end
    
    @leaderboard = {
      l2015_08_17: [
        { college: "Federal Institute of Science and Technology", team_lead: "Aravind Murali" },
        { college: "M.A. College of Engineering Kothamangalam", team_lead: "Stenal P Jolly" },
        { college: "Government College of Engineering Thrissur", team_lead: "Arya Murali" },
        { college: "Government College of Engineering Thrissur", team_lead: "Felix Josemon" },
        { college: "Saintgits College of Engineering Pathamuttom", team_lead: "Nakendra Kumar S." },
        { college: "Rajagiri School Of Engineering & Technology", team_lead: "Akash C A" },
        { college: "Saintgits College of Engineering Pathamuttom", team_lead: "Sherin Antony" },
        { college: "NSS College of Engineering, Palakkad", team_lead: "Hanzal Salim" },
        { college: "Sahrdaya College Of Engineering And Technology Kodakara", team_lead: "Anik Raj" },
        { college: "Model Engineering College", team_lead: "Ajmal Azeez" },
        { college: "Govt. Model Engineering College Thrikkakara ", team_lead: "Mohammed Akhil P R" },
        { college: "School Of Engineering, CUSAT", team_lead: "Athul B Raj" },
        { college: "Sree Chitra Thirunal College of Engineering Trivandrum", team_lead: "Varghese George" },
        { college: "NSS College Of Engineering, Palakkad", team_lead: "Aravind Sai.V" },
        { college: "Amal Jyothi College of Engineeering", team_lead: "Francis Alexander" },
        { college: "Sree Narayana Gurukulam college of Engineering Kadayiruppu", team_lead: "Anand B" },
        { college: "Rajagiri School of Engineering and Technology", team_lead: "Geordin Jose" },
        { college: "College of Engineering Chengannur", team_lead: "Sachu S" },
        { college: "Adi Shankara Institute of Engineering and Technology", team_lead: "A N Sreeram" },
        { college: "College of Engineering Vadakara", team_lead: "Tashrif Yusuf" },
        { college: "Muthoot Institute of Technology and Science, Varikoli", team_lead: "Aravind Muraleedharan" },
        { college: "AWH Engineering College", team_lead: "Alen Thomas" }
      ],
      l2015_08_24: [
        { rank: '1', change_from_last_leaderboard: '', startup_name: 'Codesap Tech LLP', startup_timeline: 'codesap', team_lead: 'Alen Thomas' },
        { rank: '2', change_from_last_leaderboard: '', startup_name: 'Creazone', startup_timeline: 'creazone-415', team_lead: 'Felix Josemon' },
        { rank: '3', change_from_last_leaderboard: '', startup_name: '10s', startup_timeline: '10s', team_lead: 'Arya Murali' },
        { rank: '3', change_from_last_leaderboard: '', startup_name: '(College) Saintgits College of Engineering', startup_timeline: '', team_lead: 'Nakendra Kumar S.' },
        { rank: '5', change_from_last_leaderboard: '', startup_name: '(College) Sree Chitra Thirunal College of Engineering, Trivandrum', startup_timeline: '', team_lead: 'Varghese George' },
        { rank: '6', change_from_last_leaderboard: '', startup_name: '(College) School Of Engineering, CUSAT', startup_timeline: '', team_lead: 'Athul B Raj' },
        { rank: '7', change_from_last_leaderboard: '', startup_name: 'HandMe', startup_timeline: 'handme', team_lead: 'Arun P' },
        { rank: '7', change_from_last_leaderboard: '', startup_name: '(College) Rajagiri School of Engineering and Technology', startup_timeline: '', team_lead: 'Geordin Jose' },
        { rank: '7', change_from_last_leaderboard: '', startup_name: '(College) Adi Shankara Institute of Engineering and Technology', startup_timeline: '', team_lead: 'A N Sreeram' },
        { rank: '7', change_from_last_leaderboard: '', startup_name: 'CreditoFlux', startup_timeline: 'creditoflux', team_lead: 'Sachu S' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: 'Semantica', startup_timeline: 'semantica', team_lead: 'Stenal P Jolly' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: 'Tapiko', startup_timeline: 'tapiko', team_lead: 'Anik Raj' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: 'Grey Codes', startup_timeline: 'greycodes', team_lead: 'Ajmal Azeez' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: '(College) Saintgits College of Engineering Pathamuttom', startup_timeline: '', team_lead: 'Sherin Antony' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: '(College) Govt. Model Engineering College, Thrikkakara', startup_timeline: '', team_lead: 'Mohammed Akhil P R' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: 'Investo', startup_timeline: 'investo', team_lead: 'Tashrif Yusuf' },
        { rank: '11', change_from_last_leaderboard: '', startup_name: 'Openloop Labs', startup_timeline: 'openloop', team_lead: 'Francis Alexander' },
        { rank: '18', change_from_last_leaderboard: '', startup_name: '(College) Sree Narayana Gurukulam college of Engineering, Kadayiruppu', startup_timeline: '', team_lead: 'Anand B' },
        { rank: '19', change_from_last_leaderboard: '', startup_name: 'Bash', startup_timeline: 'bash', team_lead: 'Hanzal Salim' },
        { rank: '20', change_from_last_leaderboard: '', startup_name: 'Tega', startup_timeline: 'tega', team_lead: 'Aravind Muraleedharan' },
        { rank: '21', change_from_last_leaderboard: '', startup_name: '(College) NSS College Of Engineering, Palakkad', startup_timeline: '', team_lead: 'Aravind Sai.V' },
        { rank: '22', change_from_last_leaderboard: '', startup_name: '(College) Rajagiri School Of Engineering & Technology', startup_timeline: '', team_lead: 'Joseph Biju Cadavil' }
      ]
    }
  end
  
  def press_kit
    @press_kit_url = "https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing"
  end

  private

  def faculty_image_path(type, image)
    "faculty/#{type}/". #Images are stored in a subfolder in faculty/
      +(image).
      gsub('Dr. ', ''). #Remove Salutations
      gsub('.', '_'). #Convert initials to underscores
      gsub(' ', '_'). #Convert spaces to underscores
      underscore. #Convert to underscore case
      gsub(/_+/, '_'). #Convert multiple underscores to one
      +(".png") #PNG image
  end
  
  rescue_from ActionView::MissingTemplate do |exception|
    raise_not_found
  end

  helper_method :render_and_rescue
  helper_method :faculty_image_path
end
