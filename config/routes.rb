EventEngine::Engine.routes.draw do
  namespace :dashboard do
    root to: "home#index"
    resources :events, only: [:index, :show]
  end
end
