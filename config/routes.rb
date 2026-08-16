Rails.application.routes.draw do
  root "pages#home"
  get "how-to", to: "pages#how_to", as: :how_to

  get "lists/:token/ogp", to: "lists#ogp_image", as: :list_ogp_image
  get "lists/:token/list_items/:id/pixiv_title",
      to: "lists#pixiv_title",
      as: :list_item_pixiv_title

  resources :lists, param: :token, only: %i[new create show]
end
