# Integração JavaScript - Engine Universidade

## Arquitetura

A engine foi configurada para funcionar tanto standalone quanto montada em um monolito.

### Arquivos Principais

1. **init.js**: Inicializa Stimulus em modo standalone (importa @hotwired/stimulus e @hotwired/turbo-rails)
2. **application.js**: Entry point que importa controllers
3. **controllers/index.js**: Registra todos os controllers no `window.Stimulus`
4. **controllers/*_controller.js**: Controllers Stimulus que usam `window.Stimulus.Controller`

### Modo Standalone (via importmap)

O importmap.rb carrega na seguinte ordem:
1. @hotwired/turbo-rails
2. @hotwired/stimulus  
3. universidade/init.js (inicializa window.Stimulus)
4. application.js (carrega controllers)
5. controllers são registrados

### Modo Monolito

**Requisitos:**
- Monolito DEVE garantir que `window.Stimulus` existe antes de carregar qualquer JS da engine
- Monolito DEVE usar importmap-rails (não Sprockets/asset pipeline para ES modules)

**Configuração Recomendada:**

No `config/importmap.rb` do monolito:
```ruby
# Suas dependências do monolito
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true  
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# NÃO carregar init.js da engine (o monolito já tem Stimulus)
# Carregar apenas os controllers da engine
pin "universidade/controllers", to: "universidade/controllers/index.js"
```

No layout do monolito (application.html.erb):
```erb
<%= javascript_importmap_tags %>
```

**IMPORTANTE:** Não use `javascript_include_tag` para carregar ES modules. Use importmap.

### Problemas Conhecidos

Se você vê erros 404 para controllers no console, significa que:
1. O monolito está usando `javascript_include_tag` em vez de `javascript_importmap_tags`
2. Os controllers estão sendo carregados via Sprockets que não processa ES modules corretamente

**Solução:** Configure o monolito para usar importmap-rails e `javascript_importmap_tags`.

### Como o Stimulus é Detectado

Todos os controllers usam `window.Stimulus.Controller` diretamente. A ordem de carregamento garante que `window.Stimulus` sempre existe antes dos controllers carregarem.

- **Standalone**: init.js cria window.Stimulus
- **Monolito**: monolito já criou window.Stimulus

NÃO há dynamic imports ou requires - tudo é import estático de ES modules.
