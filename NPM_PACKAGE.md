# @majestic/universidade

Sistema de gerenciamento de aprendizagem (LMS) como Rails Engine com Stimulus controllers.

## 📦 Instalação

### No monolito (com esbuild)

No seu `package.json`, adicione como dependência local:

```json
{
  "dependencies": {
    "@majestic/universidade": "file:../universidade_ink"
  }
}
```

Depois instale:

```bash
yarn install
```

### Ou como npm package publicado

```bash
yarn add @majestic/universidade
# ou
npm install @majestic/universidade
```

## 🚀 Uso

### Opção 1: Auto-registro (Recomendado)

A forma mais simples é deixar a engine registrar automaticamente os controllers quando `window.Stimulus` existir:

```javascript
// app/javascript/application.js
import { Application } from "@hotwired/stimulus"

// Inicializa Stimulus
const application = Application.start()
window.Stimulus = application

// Importa a engine - controllers registram automaticamente
import "@majestic/universidade"
```

### Opção 2: Registro Manual

Se você preferir controle total sobre o registro:

```javascript
// app/javascript/application.js
import { Application } from "@hotwired/stimulus"
import { registerUniversidadeControllers } from "@majestic/universidade"

// Inicializa Stimulus
const application = Application.start()
window.Stimulus = application

// Registra controllers da Universidade
registerUniversidadeControllers(application)
```

### Opção 3: Importar controllers individuais

Para usar apenas alguns controllers específicos:

```javascript
import { ModalController, EditorController } from "@majestic/universidade"

application.register("modal", ModalController)
application.register("editor", EditorController)
```

## 🎮 Controllers Disponíveis

A engine exporta 23 Stimulus controllers:

| Controller | Identificador | Uso |
|-----------|--------------|-----|
| AccordionController | `universidade--accordion` | Acordeões expansíveis |
| AnalyticsController | `universidade--analytics` | Tracking de eventos |
| BlocksEditorController | `universidade--blocks-editor` | Editor de blocos de conteúdo |
| BuscaRapidaController | `universidade--busca-rapida` | Busca rápida |
| CarrosselController | `universidade--carrossel` | Carrossel de imagens |
| CategoriaCreatorController | `universidade--categoria-creator` | Criação de categorias |
| CategoriaSelectorController | `universidade--categoria-selector` | Seleção de categorias |
| EditorController | `universidade--editor` | Editor de texto rico |
| HierarchicalSortableController | `universidade--hierarchical-sortable` | Ordenação hierárquica |
| MobileSidebarController | `universidade--mobile-sidebar` | Sidebar mobile |
| ModalController | `universidade--modal` | Modais |
| ModalLinkController | `universidade--modal-link` | Links que abrem modais |
| SecaoFormController | `universidade--secao-form` | Formulários de seção |
| SidebarController | `universidade--sidebar` | Sidebar de navegação |
| SidebarItemFormController | `universidade--sidebar-item-form` | Formulários de itens |
| SidebarSpacingController | `universidade--sidebar-spacing` | Espaçamento da sidebar |
| SidebarToggleController | `universidade--sidebar-toggle` | Toggle da sidebar |
| SortableController | `universidade--sortable` | Ordenação drag-and-drop |
| TagsSelectorController | `universidade--tags-selector` | Seleção de tags |
| TaxonomySuggestionsController | `universidade--taxonomy-suggestions` | Sugestões de taxonomia |
| TrilhaModuloSelectorController | `universidade--trilha-modulo-selector` | Seleção de módulos |
| TrilhasManagerController | `universidade--trilhas-manager` | Gerenciamento de trilhas |
| UserMenuController | `universidade--user-menu` | Menu do usuário |

## 📋 Dependências

A engine requer as seguintes peer dependencies:

- `@hotwired/stimulus` ^3.2.0
- `@hotwired/turbo-rails` ^7.0.0 || ^8.0.0
- `sortablejs` ^1.15.0

Certifique-se de instalá-las no seu projeto host:

```bash
yarn add @hotwired/stimulus @hotwired/turbo-rails sortablejs
```

## 🔧 Configuração no esbuild

Se estiver usando esbuild, adicione ao seu `esbuild.config.mjs`:

```javascript
import { build } from "esbuild"

build({
  entryPoints: ["app/javascript/application.js"],
  bundle: true,
  outdir: "app/assets/builds",
  loader: {
    ".js": "jsx"
  },
  // Importante: não externalizar a engine
  external: [],
})
```

Depois execute o build:

```bash
yarn build
```

## ✅ Verificação

Para verificar se tudo foi instalado corretamente, abra o console do navegador e execute:

```javascript
window.Stimulus
```

Você deve ver o objeto Application. Para ver os controllers registrados:

```javascript
Object.keys(window.Stimulus.router.modulesByIdentifier.keys)
```

Procure por controllers que começam com `universidade--`.

## 🐛 Troubleshooting

### Controllers não aparecem

1. **Verifique se window.Stimulus existe antes da importação:**
   ```javascript
   // Certifique-se de que esta linha vem ANTES do import da engine
   window.Stimulus = Application.start()
   ```

2. **Verifique se o build foi executado:**
   ```bash
   yarn build
   ```

3. **Verifique o console do navegador** para mensagens de erro

### Erro "Dynamic require not supported"

Se você ver este erro, certifique-se de que:
- Está usando a versão 0.1.0+ da engine (usa imports estáticos)
- O esbuild está configurado corretamente para bundling

### SortableJS não funciona

Certifique-se de instalar sortablejs:

```bash
yarn add sortablejs
```

## 📚 Mais Informações

Para documentação completa sobre a Rails Engine e features, veja:
- [ESBUILD_INTEGRATION.md](ESBUILD_INTEGRATION.md) - Guia completo de integração
- [QUICK_START.md](QUICK_START.md) - Início rápido
- [INTEGRATION_GUIDES.md](INTEGRATION_GUIDES.md) - Índice de guias

## 📄 Licença

MIT
