# -*- coding: utf-8 -*-
Patrick::Application.routes.draw do

  get "mine/index"
  root :to => 'static#index'
  ## ADMIN
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  ## SETTINGS
  match "/settings", :to => "settings#basic", :via => [:get, :post, :put]

  # oauth china
  match "/friends/:type/sync" => "friends#new", :as => :sync_new
  match "/friends/:type/callback" => "friends#callback", :as => :sync_callback

  ## USER
  devise_for :users, :controllers => { :registrations => "registrations" }
  devise_scope :user do
    get :login , :to => "devise/sessions#new"
    get :logout , :to => 'devise/sessions#destroy'
    get :register , :to => 'devise/registrations#new'
  end
  namespace :users do
    match ":user_id/" => "users#index"
    match ":user_id/wine_follows" => "users#wine_follows"
    match ":user_id/winery_follows" => "users#winery_follows"
    match ":user_id/comments" => "users#comments"
    match ":user_id/testing_notes" => "users#testing_notes"
    match ":user_id/user_follows" => "users#user_follows"
    match ":user_id/user_followers" => "users#user_followers"

    ## CELLAR
    match ":user_id/cellars/" => "cellars#index", :via => [:get]
    match ":user_id/cellars/edit" => "cellars#edit"
    ## BID
    match ":user_id/bid/mine" => "bid#mine", :via => [:get]
    match ":user_id/bid/list" => "bid#list"
    ## ALBUMS
    match ":user_id/albums/list" => "albums#list"
    match ":user_id/albums/show" => "albums#show"
    match ":user_id/albums/photo" => "albums#photo"
    # Syncs
    match "syncs/:type/new" => "syncs#new", :as => :sync_new
    match "syncs/:type/callback" => "syncs#callback", :as => :sync_callback
  end
  #用户注册成功后的页面
  match "users/register/success", :to => "users#register_success"
  match ':controller(/:action(/:id))', :controller => /users\/[^\/]+/

  ## API
  namespace :api do
    match "wineries/names", :to => "wineries#names"
    match "wine_varieties/index", :to => "wine_varieties#index"
  end
  match ':controller(/:action(/:id))', :controller => /api\/[^\/]+/

  ## WINE
  match "/wines/register", :to => "wines#register"

  namespace :wines do
    match ':wine_detail_id/:photos/:id' => "photos#show", :constraints => { :id => /\d+/, :wine_detail_id => /\d+/ }
  end

  # resources :photos
  resources :events

  ## MINE
  namespace :mine do

    # CELLARS
    match "cellars/add", :to => "cellars#add"
    resources :cellars

    # ALBUMS
    match "albums(/:album_id)/upload", :to => "albums#upload", :via => [:get, :post]
    #   # match "index",  :to => "albums#index"

    # WINES
    match "wines/add", :to => "wines#add"
    resources :wines
    # Message
    # match "conversations/:id/reply", :to => "conversations#reply", :via => [:get, :post]
    resources :messages
    resources :conversations
    # match "cellars/new", :to => "cellars#new", :via => [:post, :get]
  end
  match ':controller(/:action(/:id))', :controller => /mine\/[^\/]+/


  ## SEARCHS
  match "searches/search_wines", :to => "searches#search_wines"
  resources :searches

  ## WINERIES
  resources :wineries
  resources :wines
  ## STATIC
  match "/about_us", :to => "static#about_us"
  match "/contact_us", :to => "static#contact_us"
  match "/help", :to => "static#help"
  match "/private", :to => "static#private"
  match "/site_map", :to => "static#site_map"
  match "/home", :to => "static#home"

  ## GLOBAL
  match ':controller(/:action(/:id(.:format)))'
  #match ':controller(/:user_id(/:action(.:format)))'
end
