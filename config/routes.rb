Rails.application.routes.draw do
  root "pages#home"

  get "lists/:token/ogp", to: "lists#ogp", as: :list_ogp

  resources :lists, param: :token, only: %i[new create show]
end
