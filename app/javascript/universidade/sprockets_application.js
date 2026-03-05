// Entry point para Sprockets (bundled via esbuild)
// Usa imports relativos — compatível com bundler
import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"

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

let application
if (typeof window !== "undefined" && window.Stimulus) {
  application = window.Stimulus
} else {
  application = Application.start()
  window.Stimulus = application
}

application.register("accordion", AccordionController)
application.register("analytics", AnalyticsController)
application.register("blocks-editor", BlocksEditorController)
application.register("busca-rapida", BuscaRapidaController)
application.register("carrossel", CarrosselController)
application.register("categoria-creator", CategoriaCreatorController)
application.register("categoria-selector", CategoriaSelectorController)
application.register("editor", EditorController)
application.register("hierarchical-sortable", HierarchicalSortableController)
application.register("mobile-sidebar", MobileSidebarController)
application.register("modal", ModalController)
application.register("modal-link", ModalLinkController)
application.register("secao-form", SecaoFormController)
application.register("sidebar", SidebarController)
application.register("sidebar-item-form", SidebarItemFormController)
application.register("sidebar-spacing", SidebarSpacingController)
application.register("sidebar-toggle", SidebarToggleController)
application.register("sortable", SortableController)
application.register("tags-selector", TagsSelectorController)
application.register("taxonomy-suggestions", TaxonomySuggestionsController)
application.register("trilha-modulo-selector", TrilhaModuloSelectorController)
application.register("trilhas-manager", TrilhasManagerController)
application.register("user-menu", UserMenuController)
