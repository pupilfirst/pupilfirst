module Organisations
  class StudentsController < ApplicationController
    before_action :authenticate_user!
    layout 'student'

    def show
    end
  end
end
