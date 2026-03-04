Universidade::Engine.routes.draw do
  # Páginas de exibição para lojistas
  root to: "home#index"

  resources :trilhas, only: [:show]

  resources :conteudos, only: [:show] do
    member do
      post :concluir
      post :feedback
    end
  end

  get "busca/rapida", to: "busca#rapida", as: :busca_rapida
  get "busca", to: "busca#index", as: :busca

  # Área administrativa
  namespace :admin do
    root to: "trilhas#index"

    post :rich_image_upload, to: "uploads#image"

    # Taxonomia: Categorias e Tags
    resources :categorias
    resources :tags do
      collection do
        post :buscar_sugestoes
      end
    end

    # Sidebar
    resources :sidebar_items, except: [:show] do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
      end
    end

    # Landing Page (Seções)
    resources :secoes, path: :lp do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    # Gestão de Trilhas
    resources :trilhas do
      collection { patch :reorder }
      member do
        get :confirmar_exclusao
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
        get :selecionar_conteudos_existentes
        post :adicionar_conteudos_existentes
      end
    end

    resources :modulos do
      collection { patch :reorder }
      member do
        get :confirmar_exclusao
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    resources :conteudos do
      collection { patch :reorder }
      member do
        patch :toggle_visivel
        patch :mover_acima
        patch :mover_abaixo
      end
    end

    # Biblioteca de Conteúdos
    resources :biblioteca, except: [:show] do
      member do
        patch :toggle_visivel
        delete :desvincular_trilha
      end
    end
  end
end
