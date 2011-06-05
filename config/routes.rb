WeBTC::Application.routes.draw do

  devise_for :users

  match 'accounts/show' => 'accounts#show', :as => :account
  resources :accounts
  resources :addresses
  get 'transactions/autocomplete_address' => 'transactions#autocomplete_address', :as => :transaction_autocomplete_address
  match 'transactions/check' => 'transactions#check', :as => :check_transaction
  match 'transactions/commit' => 'transactions#commit', :as => :commit_transaction
  resources :transactions

  root :to => "accounts#index"

end
