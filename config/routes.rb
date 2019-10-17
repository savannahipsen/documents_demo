Rails.application.routes.draw do
  resources :tags
  resources :uploads
  resources :documents do
    collection do
      get :search
    end
  end

  get '/documents/search', to: 'documents#search', as: 'document_search'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
