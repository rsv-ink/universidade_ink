# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planned
- Sistema de busca avançada
- Exportação de relatórios
- Notificações por email

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

[Unreleased]: https://github.com/seu-usuario/universidade/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/seu-usuario/universidade/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/seu-usuario/universidade/releases/tag/v0.0.1
