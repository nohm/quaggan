Quaggan::Application.routes.draw do
  root :to => "home#index"

  match '/:id', to: 'links#show', via: :get
  match '/', to: 'links#create', via: :post
end
