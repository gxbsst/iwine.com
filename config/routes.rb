Patrick::Application.routes.draw do

  get "mine/index"

  root :to => 'static#index'
  ## ADMIN
  ActiveAdmin.routes(self)
  devise_for :admin_users, ActiveAdmin::Devise.config

  ## SETTINGS

  match "/settings/", :to => "settings#basic"

  get "settings/privacy"

  get "settings/invite"

  get "settings/sync"

  get "settings/account"


  ## USER
  devise_for :users, :controllers => { :registrations => "registrations" }

  devise_scope :user do
    get :login , :to => "devise/sessions#new"
    get :logout , :to => 'devise/sessions#destroy'
    get :register , :to => 'devise/registrations#new'
  end

  #用户注册成功后的页面
  match "users/register/success", :to => "users#register_success"


  namespace :users do
    ## CELLAR
    match ":user_id/cellars/" => "cellars#index", :via => [:get]
    match ":user_id/cellars/edit" => "cellars#edit"

    ## BID
    match ":user_id/bid/mine" => "bid#mine", :via => [:get]
    match ":user_id/bid/list" => "bid#list"

    ## ALBUMS
    get 'albums/new'
    post 'albums/new'

    #match "albums/new" => "albums/#new", :via => [:get, :post]
    #match "albums/:action", :via => [:get, :post]

    get 'albums/create'
    get 'albums/show'

    get 'albums/upload'
    post 'albums/upload'

    post 'albums/upload_list'

    get 'albums/delete'
    post 'albums/delete'

    get 'albums/delete_photo'
    post 'albums/delete_photo'

    post 'albums/save_upload_list'

    get 'albums/photo'

    get 'albums/edit'
    post 'albums/edit'

    get 'albums/list'
  end

  ## API
  namespace :api do
    match "wineries/names", :to => "wineries#names"
    match "wine_varieties/index", :to => "wine_varieties#index"
  end

  ## WINE
  # resources :wines
  match "/wines/register", :to => "wines#register"

  namespace :wines do
    match ':wine_detail_id/:photos/:id' => "photos#show", :constraints => { :id => /\d+/, :wine_detail_id => /\d+/ }
  end

  resources :photos
  resources :events

  ## MINE
  match '', to: 'mine#show', constraints: {subdomain: /.+/}
  namespace :mine do
    # CELLARS
    resource :cellars
    match "cellars/add", :to => "cellars#add"
    
    # ALBUMS
    resource :albums
    
    # WINES
    resource :wines
    
    # match "cellars/new", :to => "cellars#new", :via => [:post, :get]
  end

  ## SEARCHS
  resources :searches
  
  ## STATIC
  match "/about_us", :to => "static#about_us"
  match "/contact_us", :to => "static#contact_us"
  match "/help", :to => "static#help"
  match "/private", :to => "static#private"
  match "/site_map", :to => "static#site_map"
  match "/home", :to => "static#home"

  match ':controller(/:action(/:id(.:format)))'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

end
