# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planned
- Sistema de busca avançada
- Exportação de relatórios
- Notificações por email

## [0.1.7] - 2026-03-05

### Changed
- **Migração de importmap para Sprockets + esbuild**: JavaScript da engine agora é bundlado via esbuild e servido pelo Sprockets, eliminando a dependência de `importmap-rails`
- Layouts `application.html.erb` e `admin.html.erb` agora usam `javascript_include_tag` em vez de `javascript_importmap_tags`
- `engine.rb` atualizado: inicializador do importmap removido, builds path adicionado ao asset pipeline

### Added
- `app/javascript/universidade/sprockets_application.js`: entry point para o bundle (importa Turbo + todos os controllers)
- `app/assets/builds/universidade/`: diretório de output do esbuild, servido pelo Sprockets
- Scripts `build` e `build:watch` no `package.json` via esbuild (formato IIFE, target ES2017)

### Removed
- Dependência `importmap-rails` do gemspec e Gemfile
- Inicializador `universidade.importmap` do engine.rb
- `config/importmap.rb` da engine (não mais necessário)

### Technical
- esbuild adicionado como devDependency (`^0.23.0`)
- Bundle inclui: `@hotwired/turbo-rails`, `@hotwired/stimulus`, `sortablejs` e todos os 23 controllers
- Para compilar: `npm run build` (ou `npm run build:watch` em desenvolvimento)

## [0.1.6] - 2026-03-04

### Added
- **NPM Package Support**: Engine agora é distribuída como pacote NPM (`@majestic/universidade`)
- `package.json` configurado com exports e peer dependencies
- `app/javascript/universidade/index.js`: Entry point para integração via NPM/yarn
- Documentação completa de integração:
  - `NPM_PACKAGE.md`: Guia completo do pacote NPM
  - `QUICK_START.md`: Setup rápido em 5 minutos
  - `INTEGRATION_GUIDES.md`: Índice de todos os guias
  - `ESBUILD_INTEGRATION.md`: Integração detalhada com esbuild
  - `INTEGRACAO_JAVASCRIPT.md`: Arquitetura JavaScript

### Changed
- **Dual Mode JavaScript**: Suporta tanto importmap (standalone) quanto NPM package (monolito)
- Controllers Stimulus agora usam imports ES6 nativos (`import { Controller } from "@hotwired/stimulus"`)
- `application.js` detecta automaticamente se `window.Stimulus` existe e adapta comportamento
- Importmap configurado para carregar dependências do CDN em modo standalone
- Asset manifest simplificado (apenas CSS, JavaScript via importmap)
- Engine agora exporta função `registerUniversidadeControllers()` para registro manual
- Controllers individuais podem ser importados seletivamente
- README.md atualizado com instruções de instalação NPM

### Fixed
- Corrigido erro `Sprockets::FileNotPrecompiledError` em modo standalone
- Corrigido erro de asset não encontrado adicionando `config.assets.check_precompiled_asset = false`
- Removidas duplicatas de pins no importmap
- Controllers agora registram com nomes corretos (sem prefixo em standalone, com prefixo em NPM)
- Paths de import corrigidos para funcionar com importmap

### Technical
- 23 Stimulus controllers totalmente funcionais
- Compatível com esbuild, webpack, vite e outros bundlers modernos
- Peer dependencies: @hotwired/stimulus ^3.2.0, @hotwired/turbo-rails ^7-8, sortablejs ^1.15.0
- Suporte a tree-shaking e code splitting
- Auto-registro inteligente de controllers

## [0.1.5] - 2026-03-04

### Changed
- JavaScript adaptado para funcionar com esbuild
- `application.js` atualizado para bundlers externos
- Controllers Stimulus agora usam instância compartilhada (`window.Stimulus`)
- Layouts atualizados para carregar JavaScript do host app primeiro

### Added
- Suporte a integração com sistemas de build modernos (esbuild, webpack, etc)
- Documentação de integração com monolitos

## [0.1.4] - 2026-03-04

### Fixed
- Removido `skip_before_action :authenticate_universidade!` do Admin::BaseController
- Ação não existia mais desde a v0.1.2

## [0.1.3] - 2026-03-04

### Fixed
- Corrigido erro de migrações duplicadas no projeto host
- Removido carregamento automático de migrações da engine
- Migrações agora devem ser instaladas via `rails universidade:install:migrations`

## [0.1.2] - 2026-03-04

### Changed
- Autenticação agora é opcional, delegada ao projeto host
- ApplicationController não força mais autenticação via before_action

### Removed
- Sistema de autenticação obrigatório (`authenticate_universidade!`)
- Método `user_in_universidade?` e validações relacionadas
- Referência ao método `in_universidade?` na documentação

## [0.1.1] - 2026-03-04

### Added
- Sistema de autenticação e controle de acesso à engine
- Método `authenticate_universidade!` para proteger rotas
- Verificação de permissões via `user_in_universidade?`
- Redirecionamento com alerta para usuários sem acesso

### Changed
- ApplicationController agora valida acesso do usuário antes de permitir navegação

## [0.1.0] - 2026-03-04

### Added
- **Sistema de Taxonomia**
  - Implementação de categorias e tags
  - Relacionamentos muitos-para-muitos entre conteúdos e tags
  - Relacionamentos muitos-para-muitos entre trilhas e tags
  - Slugs únicos para categorias e tags
  - Sistema de sidebar configurável

- **Nova Hierarquia de Conteúdo**
  - Trilhas (anteriormente Cursos)
  - Módulos dentro de trilhas
  - Conteúdos (anteriormente Artigos)
  - Tabela de join trilha_conteudos para relação muitos-para-muitos
  - Suporte a conteúdos soltos (sem módulo)

- **Sistema de Seções**
  - Criação de seções personalizáveis
  - Layouts: padrão, galeria
  - Galeria responsiva com colunas configuráveis (desktop e mobile)
  - Suporte a imagens com ordem e links customizados
  - Itens polimórficos (trilhas, conteúdos, etc.)

- **Sistema de Progresso**
  - Rastreamento de progresso por usuário
  - Status: não iniciado, em andamento, concluído
  - Percentual de conclusão
  - Feedback de usuários sobre conteúdos

- **Multi-tenancy**
  - Suporte a user_id e store_id em todas as tabelas principais
  - Isolamento de dados por loja

- **Features Gerais**
  - Rascunhos para trilhas, módulos e conteúdos
  - Ordenação customizável
  - Controle de visibilidade
  - Tempo estimado de conclusão
  - Editor de conteúdo com corpo JSON
  - Turbo e Stimulus integrados
  - Importmap configurado

### Changed
- Migração de `universidade_cursos` para `universidade_trilhas`
- Migração de `universidade_artigos` para `universidade_conteudos`
- Todas as migrações padronizadas para ActiveRecord::Migration[7.2]

### Removed
- Tabela `universidade_comentarios` (substituída por feedbacks)

### Technical
- Ruby >= 3.0
- Rails >= 7.0.8.7
- PostgreSQL como banco de dados padrão
- Engine Rails mountable

## [0.0.1] - 2026-02-24

### Added
- Estrutura inicial da gem
- Models básicos: Curso, Módulo, Trilha, Artigo
- Controllers básicos
- Views iniciais
- Migrações de banco de dados

---

## Tipos de Mudanças

- **Added** - Novas funcionalidades
- **Changed** - Mudanças em funcionalidades existentes
- **Deprecated** - Funcionalidades que serão removidas
- **Removed** - Funcionalidades removidas
- **Fixed** - Correções de bugs
- **Security** - Correções de segurança
- **Technical** - Mudanças técnicas/infraestrutura

[Unreleased]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.7...HEAD
[0.1.7]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/rsv-ink/universidade_ink/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/rsv-ink/universidade_ink/releases/tag/v0.0.1
