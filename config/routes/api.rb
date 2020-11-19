namespace :api do
  namespace :schools do
    resources :courses, only: %i[index] do
      get :students, action: :students
      post :students, action: :create_students
    end
  end
end
