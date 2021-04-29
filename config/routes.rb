Rails.application.routes.draw do
  mount Users::Base => '/'
  mount Drafts::Base => '/'
  mount Cubes::Base => '/'
  mount Participants::Base => '/'
end
