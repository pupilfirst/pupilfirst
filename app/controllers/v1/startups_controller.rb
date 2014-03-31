class V1::StartupsController < V1::BaseController

  skip_before_filter :require_token, only: [:index, :show, :load_suggestions]

  def index
    category = Category.startup_category.find_by_name(params['category']) rescue nil
    clause = category ? ["category_id = ?", category.id] : nil
    @startups = if params[:search_term]
        Startup.valid.where("name ilike ?", "#{params[:search_term]}%")
      else
        Startup.joins(:categories).valid.where(clause).order("id desc").uniq
      end
    respond_to do |format|
        format.json
    end
  end

  def create
    @current_user = current_user
    raise ArgumentError.new("User(#{current_user.fullname}) is already linked to startup #{current_user.startup.name}") if current_user.startup
    startup = Startup.create(startup_params.merge({
      email: current_user.email,
      founders: [@current_user]
    }))
    @current_user.verify_self!
    @current_user.update_attributes!(is_founder: true)
    startup.save(validate: false)
    StartupMailer.apply_now(startup).deliver
    respond_to do |format|
        format.json
    end
  end

  def update
    id = params[:id]
    startup = (id == "self") ? current_user.startup : Startup.find(id)
    if startup.update_attributes(startup_params)
      (directors_in_params[:directors] or []).each do |dir|
        founder = startup.founders.find(dir['id'].to_i) rescue nil
        founder.update_attributes(dir.select{|key|
          ['number_of_shares', 'is_share_holder'].include?(key)
        }.merge({is_director: true}))
      end
      if directors_in_params[:directors]
        StartupMailer.reminder_to_complete_personal_info(startup, current_user).deliver if startup_params[:company_names]
        message = "#{current_user.fullname} has listed you as a Director at #{startup.name}"
        startup.reload.directors.reject { |e| e.id == current_user.id }.each do |dir|
          UserPushNotifyJob.new.async.perform(dir.id, :fill_personal_info, message)
        end
      end
      render json: {message: startup.incorporation_message}, status: :ok
    else
      render json: {error: startup.errors.to_a.join(', ')}, status: :bad_request
    end
  end

  def show
    @startup = Startup.find(params[:id])
    respond_to do |f|
      f.json
    end
  end

  def load_suggestions
    @suggestions = Startup.where("name ilike ?", "#{params[:term]}%")
  end

  def link_employee
    @new_employee = current_user
    startup = Startup.find(params[:id])
    @new_employee.update_attributes!(startup: startup, startup_link_verifier_id: nil, title: params[:position])
    StartupMailer.respond_to_new_employee(startup, @new_employee).deliver
    message = "#{@new_employee.fullname} wants to be linked with #{startup.name or "your startup"}. Please check your email to approve."
    startup.founders.each do |f|
      UserPushNotifyJob.new.async.perform(f.id, :fill_personal_info, message)
    end
    # render nothing: true, status: :created
  end

  def partnership_application
    if current_user.startup.partnership_application?
      render json: {error: "Already applied to Partnership"}, status: :bad_request
    else
      current_user.startup.update_attributes!(partnership_application: true)
      StartupMailer.partnership_application(current_user.startup, current_user).deliver
      render nothing: true, status: :created
    end
  end

  private
  def startup_params
    params.require(:startup).permit(:name, :phone, :pitch, :website,:dsc, :transaction_details,
                                    :logo, :about, :phone, :email, :facebook_link, :twitter_link,
                                    company_names: [:justification, :name],
                                    police_station: [:city, :line1, :line2, :name, :pin],
                                    registered_address_attributes: [:flat, :building, :street, :area, :town, :state, :pin]
                                    )
  end

  def directors_in_params
    params.require(:startup).permit(directors: [:id, :is_share_holder, :number_of_shares])
  end
end
