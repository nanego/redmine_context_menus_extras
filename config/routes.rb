resources :issues do
  shallow do
    resources :relations, :controller => 'issue_relations', :only => [:index, :show, :create, :destroy] do
      collection do
        get 'bulk_new'
        post 'bulk_create'
      end
    end
  end
end
