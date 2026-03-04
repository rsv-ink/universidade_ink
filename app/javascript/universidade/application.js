// Entry point para modo standalone/importmap
// Se window.Stimulus já existe (dummy app), usa ele
// Senão, inicializa novo (engine standalone pura)
import { Application } from "@hotwired/stimulus"

let application
if (typeof window !== 'undefined' && window.Stimulus) {
  application = window.Stimulus
  console.log("✓ Universidade: Usando Stimulus existente")
} else {
  application = Application.start()
  window.Stimulus = application
  console.log("✓ Universidade: Stimulus inicializado")
}

// Importa todos os controllers (usando paths do importmap)
import EditorController from "universidade/controllers/editor_controller"
import BlocksEditorController from "universidade/controllers/blocks_editor_controller"
import AccordionController from "universidade/controllers/accordion_controller"
import ModalController from "universidade/controllers/modal_controller"
import ModalLinkController from "universidade/controllers/modal_link_controller"
import SortableController from "universidade/controllers/sortable_controller"
import HierarchicalSortableController from "universidade/controllers/hierarchical_sortable_controller"
import SidebarController from "universidade/controllers/sidebar_controller"
import SidebarToggleController from "universidade/controllers/sidebar_toggle_controller"
import SidebarSpacingController from "universidade/controllers/sidebar_spacing_controller"
import SidebarItemFormController from "universidade/controllers/sidebar_item_form_controller"
import MobileSidebarController from "universidade/controllers/mobile_sidebar_controller"
import CarrosselController from "universidade/controllers/carrossel_controller"
import SecaoFormController from "universidade/controllers/secao_form_controller"
import TrilhaModuloSelectorController from "universidade/controllers/trilha_modulo_selector_controller"
import TrilhasManagerController from "universidade/controllers/trilhas_manager_controller"
import AnalyticsController from "universidade/controllers/analytics_controller"
import UserMenuController from "universidade/controllers/user_menu_controller"
import TaxonomySuggestionsController from "universidade/controllers/taxonomy_suggestions_controller"
import TagsSelectorController from "universidade/controllers/tags_selector_controller"
import CategoriaSelectorController from "universidade/controllers/categoria_selector_controller"
import CategoriaCreatorController from "universidade/controllers/categoria_creator_controller"
import BuscaRapidaController from "universidade/controllers/busca_rapida_controller"

// Registra todos os controllers (sem prefixo para modo standalone)
application.register("editor", EditorController)
application.register("blocks-editor", BlocksEditorController)
application.register("accordion", AccordionController)
application.register("modal", ModalController)
application.register("modal-link", ModalLinkController)
application.register("sortable", SortableController)
application.register("hierarchical-sortable", HierarchicalSortableController)
application.register("sidebar", SidebarController)
application.register("sidebar-toggle", SidebarToggleController)
application.register("sidebar-spacing", SidebarSpacingController)
application.register("sidebar-item-form", SidebarItemFormController)
application.register("mobile-sidebar", MobileSidebarController)
application.register("carrossel", CarrosselController)
application.register("secao-form", SecaoFormController)
application.register("trilha-modulo-selector", TrilhaModuloSelectorController)
application.register("trilhas-manager", TrilhasManagerController)
application.register("analytics", AnalyticsController)
application.register("user-menu", UserMenuController)
application.register("taxonomy-suggestions", TaxonomySuggestionsController)
application.register("tags-selector", TagsSelectorController)
application.register("categoria-selector", CategoriaSelectorController)
application.register("categoria-creator", CategoriaCreatorController)
application.register("busca-rapida", BuscaRapidaController)

console.log("✓ Universidade (standalone): 23 controllers registrados")
