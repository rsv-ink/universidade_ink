/**
 * Universidade Engine - JavaScript Entry Point
 * 
 * Este arquivo exporta todos os controllers Stimulus da engine para serem
 * importados pelo monolito ou qualquer aplicação Rails que use esta engine.
 * 
 * Uso no monolito:
 * 
 * import { registerUniversidadeControllers } from "@majestic/universidade"
 * 
 * // No seu application.js:
 * import { Application } from "@hotwired/stimulus"
 * const application = Application.start()
 * window.Stimulus = application
 * 
 * // Registrar controllers da engine
 * registerUniversidadeControllers(application)
 */

// Import all controllers
import AccordionController from "./controllers/accordion_controller.js"
import AnalyticsController from "./controllers/analytics_controller.js"
import BlocksEditorController from "./controllers/blocks_editor_controller.js"
import BuscaRapidaController from "./controllers/busca_rapida_controller.js"
import CarrosselController from "./controllers/carrossel_controller.js"
import CategoriaCreatorController from "./controllers/categoria_creator_controller.js"
import CategoriaSelectorController from "./controllers/categoria_selector_controller.js"
import EditorController from "./controllers/editor_controller.js"
import HierarchicalSortableController from "./controllers/hierarchical_sortable_controller.js"
import MobileSidebarController from "./controllers/mobile_sidebar_controller.js"
import ModalController from "./controllers/modal_controller.js"
import ModalLinkController from "./controllers/modal_link_controller.js"
import SecaoFormController from "./controllers/secao_form_controller.js"
import SidebarController from "./controllers/sidebar_controller.js"
import SidebarItemFormController from "./controllers/sidebar_item_form_controller.js"
import SidebarSpacingController from "./controllers/sidebar_spacing_controller.js"
import SidebarToggleController from "./controllers/sidebar_toggle_controller.js"
import SortableController from "./controllers/sortable_controller.js"
import TagsSelectorController from "./controllers/tags_selector_controller.js"
import TaxonomySuggestionsController from "./controllers/taxonomy_suggestions_controller.js"
import TrilhaModuloSelectorController from "./controllers/trilha_modulo_selector_controller.js"
import TrilhasManagerController from "./controllers/trilhas_manager_controller.js"
import UserMenuController from "./controllers/user_menu_controller.js"

// Export individual controllers
export {
  AccordionController,
  AnalyticsController,
  BlocksEditorController,
  BuscaRapidaController,
  CarrosselController,
  CategoriaCreatorController,
  CategoriaSelectorController,
  EditorController,
  HierarchicalSortableController,
  MobileSidebarController,
  ModalController,
  ModalLinkController,
  SecaoFormController,
  SidebarController,
  SidebarItemFormController,
  SidebarSpacingController,
  SidebarToggleController,
  SortableController,
  TagsSelectorController,
  TaxonomySuggestionsController,
  TrilhaModuloSelectorController,
  TrilhasManagerController,
  UserMenuController
}

/**
 * Registra todos os controllers da Universidade em uma aplicação Stimulus
 * @param {Application} app - Instância da aplicação Stimulus
 */
export function registerUniversidadeControllers(app) {
  app.register("universidade--accordion", AccordionController)
  app.register("universidade--analytics", AnalyticsController)
  app.register("universidade--blocks-editor", BlocksEditorController)
  app.register("universidade--busca-rapida", BuscaRapidaController)
  app.register("universidade--carrossel", CarrosselController)
  app.register("universidade--categoria-creator", CategoriaCreatorController)
  app.register("universidade--categoria-selector", CategoriaSelectorController)
  app.register("universidade--editor", EditorController)
  app.register("universidade--hierarchical-sortable", HierarchicalSortableController)
  app.register("universidade--mobile-sidebar", MobileSidebarController)
  app.register("universidade--modal", ModalController)
  app.register("universidade--modal-link", ModalLinkController)
  app.register("universidade--secao-form", SecaoFormController)
  app.register("universidade--sidebar", SidebarController)
  app.register("universidade--sidebar-item-form", SidebarItemFormController)
  app.register("universidade--sidebar-spacing", SidebarSpacingController)
  app.register("universidade--sidebar-toggle", SidebarToggleController)
  app.register("universidade--sortable", SortableController)
  app.register("universidade--tags-selector", TagsSelectorController)
  app.register("universidade--taxonomy-suggestions", TaxonomySuggestionsController)
  app.register("universidade--trilha-modulo-selector", TrilhaModuloSelectorController)
  app.register("universidade--trilhas-manager", TrilhasManagerController)
  app.register("universidade--user-menu", UserMenuController)
  
  console.log("✓ Universidade: 23 controllers registrados com sucesso")
  return true
}

// Auto-register se window.Stimulus existir (para compatibilidade com importmap)
if (typeof window !== 'undefined' && window.Stimulus) {
  registerUniversidadeControllers(window.Stimulus)
}

// Default export para conveniência
export default registerUniversidadeControllers
