resources :issues do
  shallow do
    resources :relations, :controller => 'issue_relations', :only => [:index, :show, :create, :destroy] do
      collection do
        post 'bulk_create'
      end
    end
  end
end
