# Universidade

Rails Engine para gestão universitária e LMS (Learning Management System), empacotado como gem Ruby e NPM package.

## 📦 Dual Package: Ruby Gem + NPM

Esta engine é distribuída de duas formas:

1. **Ruby Gem** - Para integração Rails (modelos, controllers, views, rotas)
2. **NPM Package** (`@majestic/universidade`) - Para JavaScript/Stimulus controllers

## 🚀 Quick Start

### 1. Instalar Gem

```ruby
# Gemfile
gem "universidade", path: "../universidade_ink"
```

```bash
bundle install
rails universidade:install:migrations
rails db:migrate
```

### 2. Montar Engine

```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount Universidade::Engine => "/universidade"
end
```

### 3. Integrar JavaScript

```bash
# No diretório do app host
yarn add file:../universidade_ink
```

```javascript
// app/javascript/application.js
import { Application } from "@hotwired/stimulus"
window.Stimulus = Application.start()

import "@majestic/universidade"
```

```bash
yarn build
```

**Documentação completa:** [QUICK_START.md](QUICK_START.md)

---

## Tecnologias

- Ruby on Rails 7+
- Hotwire (Turbo + Stimulus)
- PostgreSQL
- Ink Components
- ES Modules / esbuild

## Instalação

Adicione esta linha ao Gemfile da sua aplicação:

```ruby
gem "universidade", git: "https://github.com/seu-usuario/universidade_ink.git"
```

Execute:
```bash
$ bundle install
```

Execute as migrações da engine:
```bash
$ rails universidade:install:migrations
$ rails db:migrate
```

## Uso

Monte a engine nas rotas da sua aplicação Rails (`config/routes.rb`):

```ruby
Rails.application.routes.draw do
  mount Universidade::Engine => "/universidade"
end
```

A engine estará disponível em `/universidade` na sua aplicação.

## Configuração

### Google Analytics 4

Para habilitar o tracking do Google Analytics 4, configure o tracking ID no inicializador do app host:

```ruby
# config/initializers/universidade.rb
Universidade.tracking_id_proc = -> { ENV['GA_TRACKING_ID'] }
```

O sistema rastreia automaticamente:
- **Page views**: Todas as navegações (compatível com Turbo)
- **Conclusões de conteúdo**: Quando usuário marca conteúdo como concluído
- **Buscas**: Termos pesquisados
- **Navegação entre conteúdos**: Cliques em "Próximo" e "Anterior"

#### Eventos disponíveis

| Evento | Descrição | Parâmetros |
|--------|-----------|------------|
| `page_view` | Visualização de página | `page_location`, `page_path`, `page_title` |
| `complete_content` | Conclusão de conteúdo | `content_id`, `content_title` |
| `search` | Busca realizada | `search_term` |
| `content_navigation` | Navegação entre conteúdos | `direction`, `from_content`, `to_content` |

#### Desenvolvimento e testes

Para desabilitar analytics em desenvolvimento:

```ruby
# config/initializers/universidade.rb
Universidade.tracking_id_proc = -> { Rails.env.production? ? ENV['GA_TRACKING_ID'] : nil }
```

### SEO

O sistema implementa automaticamente:
- **Meta tags dinâmicas**: title, description, canonical
- **Open Graph tags**: Para compartilhamento em redes sociais
- **Twitter Cards**: Para tweets
- **JSON-LD structured data**: 
  - `Article` para conteúdos
  - `Course` para trilhas
  - `BreadcrumbList` para navegação

Todas as meta tags são geradas automaticamente com base no conteúdo da página.

## Desenvolvimento

Para testar a engine localmente:

```bash
$ bundle install
$ cd spec/dummy
$ rails db:create db:migrate
$ rails server
```

## Estrutura

Esta é uma Rails Engine mountable seguindo o Rails way:

- `app/` - Controllers, models, views, assets e JavaScript da engine
- `config/routes.rb` - Rotas isoladas da engine
- `lib/universidade/engine.rb` - Configuração da engine
- `spec/dummy/` - Aplicação Rails de teste

## 📚 Documentação

### Guias de Integração

- **[QUICK_START.md](QUICK_START.md)** - Setup rápido (5 minutos)
- **[NPM_PACKAGE.md](NPM_PACKAGE.md)** - Documentação completa do package JavaScript
- **[INTEGRATION_GUIDES.md](INTEGRATION_GUIDES.md)** - Índice de todos os guias
- **[ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md)** - Troubleshooting e configuração avançada

### Features Implementadas

- **[TAXONOMY_IMPLEMENTATION.md](TAXONOMY_IMPLEMENTATION.md)** - Sistema de categorias e tags
- **[IMPLEMENTACAO_EXCLUSAO.md](IMPLEMENTACAO_EXCLUSAO.md)** - Sistema de exclusão em cascata
- **[INTEGRACAO_JAVASCRIPT.md](INTEGRACAO_JAVASCRIPT.md)** - Arquitetura JavaScript

### JavaScript/Stimulus Controllers

A engine inclui 23 Stimulus controllers:

- Modal, Accordion, Editor
- Sortable (drag-and-drop)
- Busca rápida, Tags, Categorias
- Analytics tracking
- Navigation, Sidebar
- E mais...

Veja [NPM_PACKAGE.md](NPM_PACKAGE.md) para lista completa e API.

## Contributing

Contribuições são bem-vindas!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
