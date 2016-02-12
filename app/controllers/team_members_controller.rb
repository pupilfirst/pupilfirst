class TeamMembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_to_startup_founders

  # GET /user/startup/team_members/new
  def new
    @team_members = current_founder.startup.team_members
    @team_member =  TeamMember.new(startup: current_founder.startup)
    render 'create_or_edit'
  end

  # POST /user/startup/team_members
  def create
    @team_members = current_founder.startup.team_members
    @team_member = TeamMember.new team_member_params.merge(startup: current_founder.startup)

    if @team_member.save
      flash[:success] = 'Added new team member!'
      redirect_to edit_user_startup_url
    else
      flash.now[:error] = 'Could not create new team member.'
      render 'create_or_edit'
    end
  end

  # GET /user/startup/team_members/:id
  def edit
    @team_members = current_founder.startup.team_members
    @team_member = @team_members.find(params[:id])
    render 'create_or_edit'
  end

  # PATCH /user/startup/team_members/:id
  def update
    @team_members = current_founder.startup.team_members
    @team_member = @team_members.find(params[:id])

    if @team_member.update(team_member_params)
      flash[:success] = 'Updated team member!'
      redirect_to edit_user_startup_url
    else
      flash.now[:error] = 'Could not update team member.'
      render 'create_or_edit'
    end
  end

  # DELETE /user/startup/team_members/:id
  def destroy
    @team_members = current_founder.startup.team_members
    @team_member = @team_members.find(params[:id])

    if @team_member.destroy
      flash[:success] = 'Deleted team member!'
      redirect_to edit_user_startup_url
    else
      flash[:error] = 'Could not delete team member.'
      render 'create_or_edit'
    end
  end

  private

  def team_member_params
    params.require(:team_member).permit(:name, :email, :avatar, roles: [])
  end

  def restrict_to_startup_founders
    return if current_founder
    raise_not_found
  end
end
