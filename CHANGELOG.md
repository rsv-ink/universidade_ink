# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planned
- Sistema de busca avançada
- Exportação de relatórios
- Notificações por email

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

[Unreleased]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/rsv-ink/universidade_ink/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/rsv-ink/universidade_ink/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/rsv-ink/universidade_ink/releases/tag/v0.0.1
