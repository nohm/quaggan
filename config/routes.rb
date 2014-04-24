Quaggan::Application.routes.draw do
  root :to => "links#index"

  match '/:id', to: 'links#show', via: :get
  match '/', to: 'links#create', via: :post
end
