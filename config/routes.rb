Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
    	devise_for :users,
                 as: :app,
                 path: 'users',
                 path_names: {
                   sign_in: 'login',
                   sign_out: 'logout',
                   registration: 'register'
                 },
                 controllers: {
                   sessions: 'api/v1/sessions',
                   registrations: 'api/v1/registrations'
                 }
      post 'cubes/create', to: 'cubes#create'
      post 'cubes/import', to: 'cubes#import'
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
