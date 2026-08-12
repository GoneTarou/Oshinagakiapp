Rails.application.routes.draw do
  root "pages#home"

  resources :lists, param: :token, only: %i[new create show]
end
