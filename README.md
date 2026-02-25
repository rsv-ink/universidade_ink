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
