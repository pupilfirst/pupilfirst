class SchoolsController < ApplicationController
  def show
    authorize current_school
  end
end
