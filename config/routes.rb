WeBTC::Application.routes.draw do

  devise_for :users

  match 'accounts/show' => 'accounts#show', :as => :account
  resources :accounts
  resources :addresses
  resources :transactions

  root :to => "accounts#index"

end
