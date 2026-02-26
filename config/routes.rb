Universidade::Engine.routes.draw do
  # Páginas de exibição para lojistas
  root to: "home#index"

  resources :cursos,  only: [:show]
  resources :trilhas, only: [:show]

  resources :artigos, only: [:show] do
    member do
      post :concluir
      post :feedback
    end
  end

  # Área administrativa
  namespace :admin do
    root to: "cursos#index"

    post :rich_image_upload, to: "uploads#image"
    
    resources :cursos do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    resources :modulos do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    resources :trilhas do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    resources :artigos do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end
  end
end
