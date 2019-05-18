class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :community, except: %i[show]
  before_action :target, except: %i[show]

  layout 'student'

  def show
    @question = authorize(Question.find(params[:id]))
    raise_not_found if @question.blank?
  end

  def new
    @question = authorize(Question.new(community: @community))

    raise_not_found if @question.blank?
  end

  private

  def community
    @community = Community.find(params[:community_id])
  end

  def target
    @target ||= begin
      if params[:target_id].present?
        t = Target.find_by(id: params[:target_id])

        # Only return the target if the target is in a course that is linked to this community.
        @community.courses.where(id: t&.course).exists? ? t : nil
      end
    end
  end
end
