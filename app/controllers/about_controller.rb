class AboutController < ApplicationController
  rescue_from ActionView::MissingTemplate, with: -> { raise_not_found }

  # GET /about
  def index
  end

  # GET /about/transparency
  def transparency
  end

  # GET /about/slack
  def slack
  end

  # GET /about/leaderboards/:year/:month/:day
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
        { rank: '1', startup_name: 'Codesap Tech LLP', startup_timeline: 'codesap', team_lead: 'Alen Thomas' },
        { rank: '2', startup_name: 'Creazone', startup_timeline: 'creazone-415', team_lead: 'Felix Josemon' },
        { rank: '3', startup_name: '10s', startup_timeline: '10s', team_lead: 'Arya Murali' },
        { rank: '3', startup_name: '(College) Saintgits College of Engineering', startup_timeline: '', team_lead: 'Nakendra Kumar S.' },
        { rank: '5', startup_name: '(College) Sree Chitra Thirunal College of Engineering, Trivandrum', startup_timeline: '', team_lead: 'Varghese George' },
        { rank: '6', startup_name: '(College) School Of Engineering, CUSAT', startup_timeline: '', team_lead: 'Athul B Raj' },
        { rank: '7', startup_name: 'HandMe', startup_timeline: 'handme', team_lead: 'Arun P' },
        { rank: '7', startup_name: '(College) Rajagiri School of Engineering and Technology', startup_timeline: '', team_lead: 'Geordin Jose' },
        { rank: '7', startup_name: '(College) Adi Shankara Institute of Engineering and Technology', startup_timeline: '', team_lead: 'A N Sreeram' },
        { rank: '7', startup_name: 'CreditoFlux', startup_timeline: 'creditoflux', team_lead: 'Sachu S' },
        { rank: '11', startup_name: 'Semantica', startup_timeline: 'semantica', team_lead: 'Stenal P Jolly' },
        { rank: '11', startup_name: 'Tapiko', startup_timeline: 'tapiko', team_lead: 'Anik Raj' },
        { rank: '11', startup_name: 'Grey Codes', startup_timeline: 'greycodes', team_lead: 'Ajmal Azeez' },
        { rank: '11', startup_name: '(College) Saintgits College of Engineering Pathamuttom', startup_timeline: '', team_lead: 'Sherin Antony' },
        { rank: '11', startup_name: '(College) Govt. Model Engineering College, Thrikkakara', startup_timeline: '', team_lead: 'Mohammed Akhil P R' },
        { rank: '11', startup_name: 'Investo', startup_timeline: 'investo', team_lead: 'Tashrif Yusuf' },
        { rank: '11', startup_name: 'Openloop Labs', startup_timeline: 'openloop', team_lead: 'Francis Alexander' },
        { rank: '18', startup_name: '(College) Sree Narayana Gurukulam college of Engineering, Kadayiruppu', startup_timeline: '', team_lead: 'Anand B' },
        { rank: '19', startup_name: 'Bash', startup_timeline: 'bash', team_lead: 'Hanzal Salim' },
        { rank: '20', startup_name: 'Tega', startup_timeline: 'tega', team_lead: 'Aravind Muraleedharan' },
        { rank: '21', startup_name: '(College) NSS College Of Engineering, Palakkad', startup_timeline: '', team_lead: 'Aravind Sai.V' },
        { rank: '22', startup_name: '(College) Rajagiri School Of Engineering & Technology', startup_timeline: '', team_lead: 'Joseph Biju Cadavil' }
      ],
      l2015_08_31: [
        { rank: '1', startup_name: 'Grey Codes', startup_timeline: 'greycodes', team_lead: 'Ajmal Azeez' },
        { rank: '2', startup_name: 'Tapiko', startup_timeline: 'tapiko', team_lead: 'Anik Raj' },
        { rank: '3', startup_name: 'Openloop Labs', startup_timeline: 'openloop', team_lead: 'Francis Alexander' },
        { rank: '4', startup_name: 'Bash', startup_timeline: 'bash', team_lead: 'Hanzal Salim' },
        { rank: '4', startup_name: 'Tega', startup_timeline: 'tega', team_lead: 'Aravind Muraleedharan' },
        { rank: '4', startup_name: 'CreditoFlux', startup_timeline: 'creditoflux', team_lead: 'Sachu S' },
        { rank: '7', startup_name: 'Zorg', startup_timeline: 'zorg', team_lead: 'Varghese George' },
        { rank: '7', startup_name: 'Inocular', startup_timeline: 'inocular', team_lead: 'Aravind Sai. V' },
        { rank: '9', startup_name: 'F5 Inc', startup_timeline: 'f5', team_lead: 'Mohammed Akhil P R' },
        { rank: '10', startup_name: 'Investo', startup_timeline: 'investo', team_lead: 'Tashrif Yusuf' },
        { rank: '11', startup_name: 'HandMe', startup_timeline: 'handme', team_lead: 'Arun P' },
        { rank: '12', startup_name: '10s', startup_timeline: '10s', team_lead: 'Arya Murali' },
        { rank: '13', startup_name: 'Codesap Tech LLP', startup_timeline: 'codesap', team_lead: 'Alen Thomas' },
        { rank: '13', startup_name: 'Creazone', startup_timeline: 'creazone-415', team_lead: 'Felix Josemon' },
        { rank: '15', startup_name: 'Semantica', startup_timeline: 'semantica', team_lead: 'Stenal P Jolly' },
        { rank: '16', startup_name: 'Thirsty Crow', startup_timeline: 'thirsty-crow', team_lead: 'Anand B' },
        { rank: '16', startup_name: 'Renaissance', startup_timeline: 'renaissance', team_lead: 'Nakendra Kumar S' },
        { rank: '16', startup_name: '(College) School Of Engineering, CUSAT', startup_timeline: '', team_lead: 'Athul B Raj' },
        { rank: '19', startup_name: 'StartRaise', startup_timeline: 'startraise', team_lead: 'Sherin Antony' },
        { rank: '20', startup_name: '(College) Rajagiri School of Engineering and Technology', startup_timeline: '', team_lead: 'Geordin Jose' },
        { rank: '21', startup_name: '(College) Adi Shankara Institute of Engineering and Technology', startup_timeline: '', team_lead: 'A N Sreeram' },
        { rank: '22', startup_name: '(College) Rajagiri School of Engineering & Technology', startup_timeline: '', team_lead: 'Joseph Biju Cadavil' }
      ]
    }

    @latest_leaderboard = @leaderboard.keys.last.to_s.gsub(/^l/, '').split('_')
  end

  def press_kit
    @press_kit_url = "https://drive.google.com/folderview?id=0B9--SdQuJvHpfjJiam1nTnJCNnVIYkY2NVFXWTQwbXNpWUFoQU1oc1RZSHJraG4yb2Y1cDA&usp=sharing"
  end
end
