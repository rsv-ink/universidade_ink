# 📚 Guias de Integração - Universidade Engine

## 🚀 Início Rápido

**Para integrar a engine no monolito**: [QUICK_START.md](QUICK_START.md) (5 minutos)

## 📖 Documentação Completa

### Integração e Setup

1. **[QUICK_START.md](QUICK_START.md)** - Setup rápido com NPM package (COMECE AQUI)
2. **[NPM_PACKAGE.md](NPM_PACKAGE.md)** - Documentação completa do package, API, e opções de uso
3. **[ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md)** - Troubleshooting e configuração avançada

### Implementação e Features

4. **[INTEGRACAO_JAVASCRIPT.md](INTEGRACAO_JAVASCRIPT.md)** - Arquitetura JavaScript da engine
5. **[TAXONOMY_IMPLEMENTATION.md](TAXONOMY_IMPLEMENTATION.md)** - Sistema de categorias e tags
6. **[IMPLEMENTACAO_EXCLUSAO.md](IMPLEMENTACAO_EXCLUSAO.md)** - Sistema de exclusão em cascata

---

## 🎯 Qual Guia Usar?

### Para integrar no monolito pela primeira vez

→ Siga: [QUICK_START.md](QUICK_START.md)

A engine agora é distribuída como **NPM package** (`@majestic/universidade`), o que torna a integração muito mais simples.

### Se controllers não estão funcionando

→ Consulte: [ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md) seção "Troubleshooting"

### Se quer entender a API e opções avançadas

→ Leia: [NPM_PACKAGE.md](NPM_PACKAGE.md)

### Se quer entender a arquitetura interna

→ Leia: [INTEGRACAO_JAVASCRIPT.md](INTEGRACAO_JAVASCRIPT.md)

---

## 📦 Estrutura do Package

```
@majestic/universidade/
├── package.json              # Metadados e dependências
├── app/javascript/universidade/
│   ├── index.js              # Entry point (exports + auto-register)
│   └── controllers/          # 23 Stimulus controllers
│       ├── modal_controller.js
│       ├── editor_controller.js
│       ├── sortable_controller.js
│       └── ...
```

**Principais exports:**

```javascript
// Registro automático
import "@majestic/universidade"

// Registro manual
import { registerUniversidadeControllers } from "@majestic/universidade"

// Controllers individuais
import { ModalController, EditorController } from "@majestic/universidade"
```

---

## 🔄 Migração de Versões Antigas

Se você está usando uma versão antiga da engine que dependia de `importmap` ou `window.Stimulus` global patterns:

### O que mudou (v0.1.0+)

- ✅ Agora é um NPM package proper
- ✅ Usa imports ES6 normais (não mais `window.Stimulus` global)
- ✅ Auto-registra controllers quando `window.Stimulus` existe
- ✅ Funciona perfeitamente com esbuild bundlers
- ❌ Não depende mais de importmap-rails na engine

### Como migrar

1. Remova imports manuais da engine do seu application.js
2. Adicione o package: `yarn add file:../universidade_ink`
3. Importe: `import "@majestic/universidade"`
4. Build: `yarn build`

Veja [QUICK_START.md](QUICK_START.md) para detalhes.

---

## 📋 Checklist de Integração

Use esta checklist para garantir que tudo está funcionando:

### Instalação
- [ ] Package adicionado ao package.json: `"@majestic/universidade": "file:../universidade_ink"`
- [ ] `yarn install` executado sem erros
- [ ] Dependências peer instaladas (@hotwired/stimulus, sortablejs)

### Configuração
- [ ] `window.Stimulus = application` adicionado ao application.js
- [ ] Import da engine após inicialização do Stimulus
- [ ] `yarn build` executado com sucesso
- [ ] Servidor reiniciado

### Verificação
- [ ] Console mostra "✓ Universidade: 23 controllers registrados com sucesso"
- [ ] `window.Stimulus` retorna objeto Application no console
- [ ] Controllers aparecem em `window.Stimulus.router.modulesByIdentifier.keys`
- [ ] Modais abrem e fecham corretamente
- [ ] Sortable funciona (drag and drop)
- [ ] Editor de texto funciona

### Troubleshooting
Se algo não funciona:
1. Verifique console do navegador por erros
2. Confirme ordem dos imports no application.js
3. Execute `yarn build` novamente
4. Limpe cache do navegador (Ctrl+Shift+R)
5. Consulte [ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md) seção "Troubleshooting"

---

## 💬 Suporte

Para problemas ou dúvidas:

1. Verifique a seção de Troubleshooting nos guias
2. Consulte logs do console do navegador
3. Verifique que todas as dependências estão instaladas
4. Confirme que `yarn build` completa sem erros

