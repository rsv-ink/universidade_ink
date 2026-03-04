# Universidade

Rails Engine para gestão universitária, empacotado como gem.

## Tecnologias

- Ruby on Rails 7+
- Hotwire (Turbo + Stimulus)
- PostgreSQL
- Ink Components

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

## Contributing

Contribuições são bem-vindas!

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
