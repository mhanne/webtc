WeBTC::Application.routes.draw do

  devise_for :users

  match 'account' => 'accounts#show', :as => :account
  match 'account/settings' => 'accounts#settings', :as => :account_settings
  match 'account/settings/update' => 'accounts#update_settings', :as => :account_update_settings
  resources :accounts
  resources :addresses
  get 'transactions/autocomplete_address' => 'transactions#autocomplete_address', :as => :transaction_autocomplete_address
  match 'transactions/check' => 'transactions#check', :as => :check_transaction
  match 'transactions/commit' => 'transactions#commit', :as => :commit_transaction
  resources :transactions

  root :to => "accounts#index"

end
