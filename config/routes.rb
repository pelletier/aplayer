Aplayer::Application.routes.draw do
  resources :songs
  root to: 'home#player'
end
