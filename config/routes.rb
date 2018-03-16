Rails.application.routes.draw do
  namespace :nacelle do
    resources :cells, only: :index
  end
end

