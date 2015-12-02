Rails.application.routes.draw do

  namespace :wcms_components do
    resources :embedded_images, only: [:create], defaults: { format: 'json' }
    resources :people, only: [:index], defaults: { format: 'json' }
    resources :tags, only: [:index], defaults: { format: 'json' }
    resources :changes, only: :index do
      get :object_index, on: :collection
      get :undo, on: :member
      get :undo_destroy, on: :member
    end
  end


  # this is just a convenience to create a named route to rack-cas' logout
  get '/logout' => -> env { [200, { 'Content-Type' => 'text/html' }, ['Rack::CAS should have caught this']] }, as: :logout

end
