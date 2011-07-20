WeBTC::Application.routes.draw do

  devise_for :users

  match 'admin' => 'admin#index', :as => :admin
  match 'admin/:id' => 'admin#show', :as => :admin_user

  match 'locale/:id' => 'accounts#locale', :as => :locale
  match 'account' => 'accounts#show', :as => :account
  match 'account/settings' => 'accounts#settings', :as => :account_settings
  match 'account/settings/update' => 'accounts#update_settings', :as => :account_update_settings
  resources :accounts
  resources :addresses
  get 'transactions/autocomplete_address' => 'transactions#autocomplete_address', :as => :transaction_autocomplete_address
  match 'transactions/verify/:id/:code' => 'transactions#verify', :as => :verify_transaction
  match 'transactions/verify/:id' => 'transactions#verify', :as => :verify_transaction
  match 'transactions/commit/:id' => 'transactions#commit', :as => :commit_transaction
  match 'transactions/import' => 'transactions#import', :as => :import_transaction
  resources :transactions
  resources :verification_rules

  root :to => "accounts#index"

end
