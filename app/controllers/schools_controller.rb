class SchoolsController < ApplicationController
  layout 'tailwind'

  def show
    authorize current_school
  end

  def curriculum
    authorize current_school
  end
end
