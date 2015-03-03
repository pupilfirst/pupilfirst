class V1::StartupJobsController < V1::BaseController
  resource_description do
    short 'Index and show for startup_jobs'
    formats ['json']
    description 'The long description of the StartupJob resource should come here'
    meta :author => 'Abdul Jaleel'
  end

  api :GET, '/startup_jobs/', 'List all startup jobs currently available'
  example '[{"id":1,"startup_id":2,"title":"illum voluptatibus","description":null,"salary":"15K - 20K","equity_max":null,"equity_min":null,"equity_vest":null,"equity_cliff":null,"created_at":"2015-02-24T15:19:48.108+05:30","updated_at":"2015-02-24T15:19:48.108+05:30","expires_on":"2015-03-24T15:19:48.110+05:30","location":"North Theronside","skills":null,"experience":null,"qualification":null,"contact_name":"Elwin Torphy MD","contact_number":"9876543211"},{"id":2,"startup_id":3,"title":"natus nisi","description":null,"salary":"~ 6000","equity_max":null,"equity_min":null,"equity_vest":null,"equity_cliff":null,"created_at":"2015-02-24T15:22:05.115+05:30","updated_at":"2015-02-24T15:22:05.115+05:30","expires_on":"2015-03-24T15:22:05.115+05:30","location":"Felipastad","skills":null,"experience":null,"qualification":null,"contact_name":"Maida Fay","contact_number":"9876543212"}]'
  def index
    @startup_jobs = StartupJob.not_expired
  end

  api :GET, "/startup_jobs/params[:id]", "Show details of startup_job with id=params[:id]"
  param :id, Fixnum, :desc => "StartupJob ID", :required => true
  example ' {"id":1,"startup_id":2,"title":"illum voluptatibus","description":null,"salary":"15K - 20K","equity_max":null,"equity_min":null,"equity_vest":null,"equity_cliff":null,"created_at":"2015-02-24T15:19:48.108+05:30","updated_at":"2015-02-24T15:19:48.108+05:30","expires_on":"2015-03-24T15:19:48.110+05:30","location":"North Theronside","skills":null,"experience":null,"qualification":null,"contact_name":"Elwin Torphy MD","contact_number":"9876543211"} '
  def show
    @startup_job = StartupJob.find(params[:id])
  end
end
