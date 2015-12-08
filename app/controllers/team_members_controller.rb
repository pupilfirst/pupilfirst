class TeamMembersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_to_startup_founders

  # GET /users/:user_id/startup/team_members/new
  def new
    @team_members = current_user.startup.team_members
    @team_member =  TeamMember.new(startup: current_user.startup)
    render 'create_or_edit'
  end

  # POST /users/:user_id/startup/team_members
  def create
    @team_members = current_user.startup.team_members
    @team_member = TeamMember.new team_member_params.merge(startup: current_user.startup)

    if @team_member.save
      flash[:success] = 'Added new team member!'
      redirect_to edit_user_startup_url(@team_member.startup)
    else
      flash.now[:error] = 'Could not create new team member.'
      render 'create_or_edit'
    end
  end

  # GET /users/:user_id/startup/team_members/:id
  def edit
    @team_members = current_user.startup.team_members
    @team_member = @team_members.find(params[:id])
    render 'create_or_edit'
  end

  # PATCH /users/:user_id/startup/team_members/:id
  def update
    @team_members = current_user.startup.team_members
    @team_member = @team_members.find(params[:id])

    if @team_member.update(team_member_params)
      flash[:success] = 'Updated team member!'
      redirect_to edit_user_startup_url(@team_member.startup)
    else
      flash.now[:error] = 'Could not update team member.'
      render 'create_or_edit'
    end
  end

  # DELETE /users/:user_id/startup/team_members/:id
  def destroy
    @team_members = current_user.startup.team_members
    @team_member = @team_members.find(params[:id])

    if @team_member.destroy
      flash[:success] = 'Deleted team member!'
      redirect_to edit_user_startup_url(@team_member.startup)
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
    return if current_user.is_founder?
    raise_not_found
  end
end
