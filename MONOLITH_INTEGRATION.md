# Guia de Integração - Universidade Engine no Monolito

## ⚠️ ATENÇÃO: Este Monolito Usa esbuild

**Este guia é para monolitos que usam importmap-rails.**

**O seu monolito usa esbuild** → Veja **[ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md)** para instruções corretas.

---

## Para Monolitos com ImportMap (alternativa)

Se o seu monolito usar importmap-rails em vez de esbuild, siga as instruções abaixo.

### Problema Atual

A engine está tentando registrar Stimulus controllers, mas `window.Stimulus` não existe quando `application.js` é carregado.

## Causa

O monolito está usando `javascript_include_tag` (Sprockets/Asset Pipeline) em vez de `javascript_importmap_tags` (ImportMap).  

O Asset Pipeline **não processa imports de ES modules corretamente**, causando:
- Erros 404 para imports relativos (./controllers, etc)
- Falha ao carregar dependências corretamente
- window.Stimulus não fica disponível na ordem certa

## Solução Correta: Usar ImportMap

### 1. Garantir que o monólito tem importmap-rails

```ruby
# Gemfile
gem 'importmap-rails'
```

```bash
bundle install
bin/rails importmap:install
```

### 2. No config/importmap.rb do MONOLITO

```ruby
# Monolito carrega suas próprias dependências primeiro
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Seus controllers do monolito
pin_all_from "app/javascript/controllers", under: "controllers"

# NÃO carregar os controllers da engine aqui - a engine se auto-registra
# A configuração da engine será incluída automaticamente via engine initializer
```

### 3. No layout do MONOLITO (app/views/layouts/application.html.erb)

```erb
<!DOCTYPE html>
<html>
  <head>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    
    <%# Use importmap-rails, NÃO javascript_include_tag %>
    <%= javascript_importmap_tags %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

### 4. No app/javascript/application.js do MONOLITO

```javascript
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "./controllers"

// Inicializar Stimulus ANTES de carregar a engine
import { Application } from "@hotwired/stimulus"
const application = Application.start()
window.Stimulus = application

// Controllers do monolito serão carregados automaticamente via stimulus-loading
```

### 5. Não fazer nada especial para a engine

A engine se auto-configurará:
- O initializer em `lib/universidade/engine.rb` adiciona automaticamente o importmap da engine
- Os controllers da engine detectarão `window.Stimulus` e se registrarão
- Tudo funciona automaticamente

## Solução Temporária: Sem ImportMap (NÃO RECOMENDADO)

Se você absolutamente não pode usar importmap no monolito, precisará:

1. Garantir que `window.Stimulus` existe ANTES de carregar qualquer JS da engine
2. Carregar os arquivos na ordem correta via `javascript_include_tag`
3. Aceitar que alguns recursos podem não funcionar corretamente

Mas isso é **fortemente desencorajado**. Use importmap.

## Verificação

Após configurar, abra o console do navegador e digite:

```javascript
window.Stimulus
```

Deve retornar o objeto Stimulus. Se retornar `undefined`, o Stimulus não foi inicializado corretamente.

Para ver se os controllers da engine foram registrados:

```javascript
window.Stimulus.router.modulesByIdentifier
```

Deve mostrar uma lista incluindo controllers como "modal", "accordion", etc.

## Ainda não funciona?

Abra o console e procure por:
- `Universidade: Waiting for Stimulus...` - Stimulus ainda não carregou
- `Universidade: Controllers registered` - Sucesso!
- `Universidade: Failed to find Stimulus after 10 attempts` - Stimulus nunca carregou

Se você vê o erro de "Failed to find Stimulus", significa que o monolito não está inicializando `window.Stimulus` corretamente.
