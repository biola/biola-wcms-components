Rails.application.routes.draw do

  namespace :wcms_components do
    resources :embedded_images, only: [:create], defaults: { format: 'json' }
    resources :people, only: [:index], defaults: { format: 'json' }
    resources :tags, only: [:index], defaults: { format: 'json' }
  end

  # this is just a convenience to create a named route to rack-cas' logout
  get '/logout' => -> env { [200, { 'Content-Type' => 'text/html' }, ['Rack::CAS should have caught this']] }, as: :logout

end
