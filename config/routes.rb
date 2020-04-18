Rails.application.routes.draw do
	devise_for :users,
             path: 'users',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'register'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
