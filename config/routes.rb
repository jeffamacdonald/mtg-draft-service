Rails.application.routes.draw do
  mount Users::Base => '/'
  mount Drafts::Base => '/'
end
