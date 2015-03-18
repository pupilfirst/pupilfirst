# class V1::StudentEntrepreneurPoliciesController < V1::BaseController

#   def create
#     sep = StudentEntrepreneurPolicy.create(sep_params.merge(user: current_user))
#     if sep.save
#       UserMailer.inform_sep_submition(current_user).deliver_later
#       render json: {message: "submited"}, status: :created
#     else
#       render json: {error: sep.errors.to_a.join(', ')}, status: :bad_request
#     end
#   end

#   private
#   def sep_params
#     params.require(:sep).permit(:certificate_pic, :university_registration_number, :address)
#   end
# end