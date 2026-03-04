# 🚀 Quick Start - Integração com NPM Package

Guia de 5 minutos para integrar a engine Universidade no seu monolito Rails com esbuild.

## Passo 1: Instalar o Package

No diretório do **monolito**, adicione a engine como dependência local:

```bash
cd /home/luizacabral/majestic_monolith

# Adicionar ao package.json
yarn add file:../universidade_ink
```

Ou manualmente edite `package.json`:

```json
{
  "dependencies": {
    "@majestic/universidade": "file:../universidade_ink",
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.12",
    "sortablejs": "^1.15.6"
  }
}
```

Depois execute:

```bash
yarn install
```

## Passo 2: Configurar application.js

Edite `app/javascript/application.js` no **monolito**:

```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

// Inicializa Stimulus
const application = Application.start()
window.Stimulus = application

// Importa controllers do monolito
import "./controllers"

// Importa e registra controllers da engine
import "@majestic/universidade"

console.log("✓ Stimulus inicializado com Universidade")
```

**Importante:** A linha `window.Stimulus = application` **DEVE** vir antes do `import "@majestic/universidade"`!

## Passo 3: Build e Teste

```bash
# No diretório do monolito
yarn build

# Inicia o servidor
bin/rails server
```

Abra o navegador e acesse uma página com modais da Universidade.

**No console do navegador**, você deve ver:

```
✓ Stimulus inicializado com Universidade
✓ Universidade: 23 controllers registrados com sucesso
```

## ✅ Checklist Rápido

- [ ] `yarn add file:../universidade_ink` executado
- [ ] `yarn install` completado sem erros  
- [ ] `@hotwired/stimulus` e `sortablejs` instalados
- [ ] `window.Stimulus = application` ANTES do import da engine
- [ ] `yarn build` executado com sucesso
- [ ] Console mostra "23 controllers registrados"
- [ ] Modais abrem corretamente

## 🐛 Problemas Comuns

### Controllers não registram

**Causa:** `window.Stimulus` não existe quando a engine tenta registrar.

**Solução:** Coloque `window.Stimulus = application` ANTES do `import "@majestic/universidade"`:

```javascript
// ✅ CORRETO
window.Stimulus = application
import "@majestic/universidade"

// ❌ ERRADO
import "@majestic/universidade"
window.Stimulus = application
```

### Erro de build

**Causa:** Dependências não instaladas.

**Solução:**
```bash
yarn add @hotwired/stimulus @hotwired/turbo-rails sortablejs
yarn build
```

### Erro "Cannot find module '@majestic/universidade'"

**Causa:** Package não instalado ou caminho incorreto.

**Solução:**
```bash
# Verifique se o package está em package.json
cat package.json | grep universidade

# Se não estiver, adicione:
yarn add file:../universidade_ink

# Depois reinstale:
yarn install
```

### Modais não funcionam

**Causa:** JavaScript não carregado ou erros no console.

**Solução:**
1. Verifique se `yarn build` foi executado
2. Abra console do navegador e procure erros
3. Confirme que `window.Stimulus` existe:
   ```javascript
   window.Stimulus
   ```
4. Verifique controllers registrados:
   ```javascript
   Object.keys(window.Stimulus.router.modulesByIdentifier.keys)
   ```

## 📚 Próximos Passos

- Para uso avançado e API completa: [NPM_PACKAGE.md](NPM_PACKAGE.md)
- Para troubleshooting detalhado: [ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md)
- Para escolher outro método de integração: [INTEGRATION_GUIDES.md](INTEGRATION_GUIDES.md)
