# ✅ Integração da Engine com Monolito usando esbuild

**Situação:** O monolito usa **esbuild** para buildar JavaScript. A engine usa **importmap** em modo standalone.

**Solução:** O monolito builda o JavaScript da engine junto com o seu próprio bundle.

---

## Como Funciona

### Engine (standalone - importmap)
- Usa `javascript_importmap_tags` no layout
- Controllers carregados via ES modules nativos

### Monolito (esbuild)
- Builda TODO o JavaScript (monolito + engine) em um único bundle
- Engine detecta ausência de importmap e NÃO tenta carregar JS próprio
- Controllers da engine são incluídos automaticamente no bundle

---

## 🔧 Configuração no Monolito

### Passo 1: Importar JavaScript da Engine

No arquivo `app/javascript/application.js` do **MONOLITO**:

```javascript
// Importar Turbo e Stimulus
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

// Inicializar Stimulus e expor globalmente ANTES de carregar a engine
const application = Application.start()
window.Stimulus = application

console.log("Monolito: Stimulus inicializado")

// Importar seus controllers do monolito
import "./controllers"

// Importar controllers da ENGINE
// Ajuste o caminho conforme a localização da engine no seu projeto
import "../../universidade_ink/app/javascript/universidade/application"
```

**IMPORTANTE:** O caminho exato depende de onde está a gem/engine:
- Se gem local: `import "../../universidade_ink/app/javascript/universidade/application"`
- Se instalada como gem: pode precisar configurar resolve paths (veja abaixo)

### Passo 2: Configurar esbuild (se necessário)

Se o esbuild não conseguir resolver o caminho da engine, adicione um alias.

No `esbuild.config.mjs` ou `package.json` (dependendo da sua configuração):

**Opção A - esbuild.config.mjs:**
```javascript
import * as esbuild from 'esbuild'
import path from 'path'

await esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  outdir: 'app/assets/builds',
  alias: {
    'universidade': path.resolve('vendor/engines/universidade_ink/app/javascript/universidade')
  },
  // ... outras configurações
})
```

**Opção B - Usar caminho relativo direto** (mais simples):
```javascript
// No application.js
import "../../universidade_ink/app/javascript/universidade/application"
```

### Passo 3: Verificar package.json

Certifique-se que o build script está correto:

```json
{
  "scripts": {
    "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=/assets",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css"
  }
}
```

### Passo 4: Layout do Monolito

No `app/views/layouts/application.html.erb` do **MONOLITO**:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>Majestic Monolith</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    
    <%# esbuild gera o bundle - use type="module" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

**NÃO** use `javascript_importmap_tags` - o monolito usa esbuild!

---

## 🚀 Build e Execução

```bash
# No diretório do MONOLITO

# Buildar JavaScript (incluindo da engine)
yarn build
# ou
npm run build

# Se tiver CSS também
yarn build:css

# Rodar servidor
bin/rails server
```

---

## ✅ Verificação

Abra o console do navegador e execute:

```javascript
// Deve mostrar o objeto Stimulus
window.Stimulus

// Deve listar todos os controllers (monolito + engine)
window.Stimulus.router.modulesByIdentifier
```

Você deve ver controllers como:
- `modal` ✓
- `accordion` ✓  
- `editor` ✓
- `sortable` ✓
- E todos os outros da engine

### Mensagens no Console

Procure por:
- `Monolito: Stimulus inicializado` ✅
- `Universidade: Controllers registered` ✅

Se não vê a segunda mensagem, o import da engine pode não estar funcionando.

---

## 🔧 Troubleshooting

### ❌ Erro: "Cannot find module 'universidade'"

**Problema:** esbuild não está resolvendo o caminho.

**Solução:** Use caminho relativo:
```javascript
import "../../universidade_ink/app/javascript/universidade/application"
```

### ❌ Erro: "window.Stimulus is undefined"

**Problema:** Stimulus não foi inicializado antes da engine tentar registrar.

**Solução:** Verifique ordem no `application.js`:
```javascript
// 1. PRIMEIRO: Inicializar Stimulus
import { Application } from "@hotwired/stimulus"
window.Stimulus = Application.start()

// 2. DEPOIS: Importar engine
import "caminho/para/universidade/application"
```

### ❌ Modais não abrem

**Checklist:**
1. ✅ Console mostra: `Universidade: Controllers registered`
2. ✅ HTML tem atributos corretos: `data-controller="modal"`
3. ✅ Controller registrado: executa no console:
   ```javascript
   window.Stimulus.router.modulesByIdentifier.has("modal")
   // deve retornar true
   ```

### ❌ Erros 404 para controllers

**Problema:** Controllers não foram buildados no bundle.

**Solução:** 
1. Verifique que o import da engine está no `application.js`
2. Rebuild: `yarn build`
3. Reinicie o servidor Rails

---

## 📝 Resumo

| Aspecto | Engine Standalone | Monolito com esbuild |
|---------|-------------------|----------------------|
| Build | Importmap nativo | esbuild bundle |
| Carregamento | `javascript_importmap_tags` | `javascript_include_tag` |
| Stimulus | Auto-inicializa | Inicializado no monolito |
| Controllers | Auto-carrega | Buildados no bundle |
| Integração | Automática | Import manual no application.js |

**Bottom line:** A engine funciona perfeitamente com esbuild! Só precisa:
1. Inicializar `window.Stimulus` no monolito ✅
2. Importar `universidade/application` ✅  
3. Buildar com esbuild ✅

Pronto! 🎉
