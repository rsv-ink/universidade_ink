# Taxonomia de Conteúdos - Implementação Completa

## Resumo

Sistema de classificação de conteúdos por **categoria** (exclusiva) e **tags** (múltiplas), com sugestão automática baseada em correspondência de texto no título e corpo do conteúdo.

---

## 📚 O que foi implementado

### 1. Estrutura de Dados (Migrations)

✅ **4 migrações criadas:**
- `20260303120000_create_universidade_categorias.rb` - Tabela de categorias
- `20260303120001_create_universidade_tags.rb` - Tabela de tags
- `20260303120002_add_categoria_to_universidade_conteudos.rb` - FK categoria_id em conteúdos
- `20260303120003_create_universidade_conteudo_tags.rb` - Tabela join muitos-para-muitos

### 2. Models

✅ **3 novos models criados:**
- `Categoria` - com validação de unicidade, geração automática de slug, scope de ordenação
- `Tag` - similar à Categoria, com scope `mais_usadas` baseado em contagem de uso
- `ConteudoTag` - join table com validação de unicidade

✅ **Model Conteudo atualizado:**
- Associações: `belongs_to :categoria`, `has_many :tags`
- Scopes de filtro: `por_categoria`, `com_tag`, `com_tags`
- Método `conteudos_relacionados(limit)` - busca conteúdos com categoria/tags em comum
- Método `texto_completo` - extrai texto do título + corpo parseado (EditorJS JSON)

### 3. Controllers Admin

✅ **CategoriasController** - CRUD completo
- Index com busca e contagem de uso
- Prevê exclusão se categoria tiver conteúdos vinculados
- Respostas Turbo Stream

✅ **TagsController** - CRUD completo
- Index com busca e 2 modos de ordenação (mais usadas / alfabética)
- Action `buscar_sugestoes` (POST) - recebe título/corpo, retorna JSON com sugestões
- Suporte para criação inline via JSON API (usado pelo JavaScript)

✅ **BibliotecaController atualizado:**
- Index: filtros por `categoria_id` e `tag_ids[]`
- Create/Update: sincroniza tags via `tag_ids`
- Permite categoria_id no strong params

### 4. Views Admin

✅ **Categorias:**
- `index.html.erb` - listagem com busca, contagens, ações
- `_form.html.erb` - formulário para new/edit (nome, descrição)
- Integração com modal via Turbo

✅ **Tags:**
- `index.html.erb` - listagem com busca, toggle de ordenação, contagens
- `_form.html.erb` - formulário simples (apenas nome)
- Integração com modal via Turbo

✅ **Biblioteca:**
- `_taxonomy_fields.html.erb` - partial reutilizável com:
  - Select de categoria
  - Multi-select customizado de tags (com busca e criação inline)
  - Seção de sugestões automáticas (aparece quando há matches)
- Partial incluído em `new.html.erb` e `edit.html.erb`
- `index.html.erb` atualizado com filtros de categoria e tags

### 5. JavaScript (Stimulus Controllers)

✅ **tags_selector_controller.js:**
- Busca tags conforme digitação
- Renderiza chips visuais para selecionadas
- Permite criar novas tags inline (POST para /admin/tags)
- Gerencia hidden inputs para submit do form
- Dropdown com resultados filtrados

✅ **taxonomy_suggestions_controller.js:**
- Escuta mudanças no título (input direto) e corpo (via MutationObserver no hidden input do editor)
- Debounce de 500ms
- POST para `/admin/tags/buscar_sugestoes` com título + corpo
- Renderiza chips clicáveis de sugestões
- Clicar em sugestão: adiciona ao select (categoria) ou ao tags-selector (tags)
- Remove sugestão após aplicá-la

### 6. Rotas

✅ Adicionado namespace admin:
```ruby
resources :categorias
resources :tags do
  collection { post :buscar_sugestoes }
end
```

### 7. Funcionalidades Públicas

✅ **HomeController:**
- Suporte a filtros `categoria_id` e `tag_ids[]` via params
- Filtra trilhas e conteúdos soltos conforme seleção
- Passa `@categorias` e `@tags` para a view

✅ **ConteudosController:**
- Método `show` carrega `@conteudos_relacionados` (até 3)
- Exclui conteúdos já concluídos pelo usuário
- Baseado em categoria/tags compartilhadas

✅ **Views públicas:**
- `home/index.html.erb` - seção de filtros com categoria e tags (multi-select), chips visuais de filtros ativos
- `conteudos/show.html.erb` - seção "Você também pode gostar" ao final, mostrando conteúdos relacionados com categoria/tags

### 8. Seeds

✅ **spec/dummy/db/seeds.rb atualizado:**
- Cria 4 categorias exemplo (Tráfego Pago, Gestão de Loja, Produtos, Atendimento)
- Cria 13 tags exemplo (instagram, meta-ads, iniciante, fotografia, etc.)
- Cria trilhas e conteúdos com categoria e tags atribuídas
- Demonstra conteúdo solto (sem trilha) com taxonomia

---

## 🎯 Funcionalidades Principais

### Gestão no Admin

1. **Categorias e Tags**  
   - Acessar em `/admin/categorias` e `/admin/tags`
   - CRUD completo com modal via Turbo
   - Busca e contagem de uso

2. **Classificar Conteúdo**  
   - No formulário de conteúdo (new/edit):
     - Select de categoria (opcional)
     - Campo de tags com busca e criação inline
     - **Sugestões automáticas** aparecem em tempo real conforme digitação
     - Chips clicáveis para aplicar sugestões

3. **Filtros na Biblioteca**  
   - Filtros por categoria e tags (múltiplas)
   - Combinam entre si (AND)

### Funcionalidades Públicas

1. **Filtros na Home**  
   - Lojistas podem filtrar trilhas e conteúdos por categoria/tags
   - Filtros visuais com chips

2. **Conteúdos Relacionados**  
   - Ao final de cada conteúdo, exibe até 3 sugestões
   - Prioriza conteúdos com mais tags em comum
   - Não exibe conteúdos já concluídos

---

## 🔄 Como a Sugestão Automática Funciona

1. **Trigger:** usuário digita no título ou edita o corpo (blocos)
2. **Debounce:** aguarda 500ms para não disparar a cada tecla
3. **Request:** POST para `/admin/tags/buscar_sugestoes` com `{titulo, corpo}`
4. **Backend:**
   - Extrai texto do corpo (parseia JSON do EditorJS para texto puro)
   - Monta `texto_completo = titulo + corpo_parseado`
   - Busca categorias/tags cujo nome aparece no texto (case-insensitive)
5. **Response:** JSON com `{categorias: [...], tags: [...]}`
6. **Frontend:** renderiza chips clicáveis na seção de sugestões
7. **Interação:** clicar no chip adiciona ao campo correspondente (não destrutivo)

---

## 📂 Arquivos Criados/Modificados

### Migrações (4)
- `db/migrate/20260303120000_create_universidade_categorias.rb`
- `db/migrate/20260303120001_create_universidade_tags.rb`
- `db/migrate/20260303120002_add_categoria_to_universidade_conteudos.rb`
- `db/migrate/20260303120003_create_universidade_conteudo_tags.rb`

### Models (3 novos + 1 atualizado)
- `app/models/universidade/categoria.rb`
- `app/models/universidade/tag.rb`
- `app/models/universidade/conteudo_tag.rb`
- `app/models/universidade/conteudo.rb` (modificado)

### Controllers (2 novos + 1 atualizado)
- `app/controllers/universidade/admin/categorias_controller.rb`
- `app/controllers/universidade/admin/tags_controller.rb`
- `app/controllers/universidade/admin/biblioteca_controller.rb` (modificado)
- `app/controllers/universidade/home_controller.rb` (modificado)
- `app/controllers/universidade/conteudos_controller.rb` (modificado)

### Views (12 arquivos)
- `app/views/universidade/admin/categorias/index.html.erb`
- `app/views/universidade/admin/categorias/new.html.erb`
- `app/views/universidade/admin/categorias/edit.html.erb`
- `app/views/universidade/admin/categorias/_form.html.erb`
- `app/views/universidade/admin/tags/index.html.erb`
- `app/views/universidade/admin/tags/new.html.erb`
- `app/views/universidade/admin/tags/edit.html.erb`
- `app/views/universidade/admin/tags/_form.html.erb`
- `app/views/universidade/admin/biblioteca/_taxonomy_fields.html.erb`
- `app/views/universidade/admin/biblioteca/new.html.erb` (modificado)
- `app/views/universidade/admin/biblioteca/edit.html.erb` (modificado)
- `app/views/universidade/admin/biblioteca/index.html.erb` (modificado)
- `app/views/universidade/home/index.html.erb` (modificado)
- `app/views/universidade/conteudos/show.html.erb` (modificado)

### JavaScript (2)
- `app/javascript/universidade/controllers/tags_selector_controller.js`
- `app/javascript/universidade/controllers/taxonomy_suggestions_controller.js`

### Rotas (1)
- `config/routes.rb` (modificado)

### Seeds (1)
- `spec/dummy/db/seeds.rb` (modificado)

---

## ✅ Verificação

Execute para popular o banco com dados de exemplo:

```bash
bin/rails db:seed
```

Acesse:
- Admin categorias: `/admin/categorias`
- Admin tags: `/admin/tags`
- Admin biblioteca: `/admin/biblioteca`
- Home pública: `/`

---

## 🎉 Conclusão

Sistema de taxonomia completo implementado com:
- ✅ Categorias (exclusivas) e Tags (múltiplas)
- ✅ CRUD admin completo
- ✅ **Sugestão automática em tempo real** no formulário
- ✅ Filtros na biblioteca (admin) e home (público)
- ✅ Conteúdos relacionados baseados em taxonomia
- ✅ Interface intuitiva com Stimulus e Turbo
- ✅ Dados de exemplo via seeds

**Pronto para uso!** 🚀
