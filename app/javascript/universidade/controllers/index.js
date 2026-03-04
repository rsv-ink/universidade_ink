import { Application } from "@hotwired/stimulus"
import EditorController        from "./editor_controller"
import BlocksEditorController  from "./blocks_editor_controller"
import AccordionController     from "./accordion_controller"
import ModalController         from "./modal_controller"
import ModalLinkController     from "./modal_link_controller"
import SortableController      from "./sortable_controller"
import HierarchicalSortableController from "./hierarchical_sortable_controller"
import SidebarController       from "./sidebar_controller"
import SidebarToggleController from "./sidebar_toggle_controller"
import SidebarSpacingController from "./sidebar_spacing_controller"
import SidebarItemFormController from "./sidebar_item_form_controller"
import MobileSidebarController from "./mobile_sidebar_controller"
import CarrosselController     from "./carrossel_controller"
import SecaoFormController    from "./secao_form_controller"
import TrilhaModuloSelectorController from "./trilha_modulo_selector_controller"
import TrilhasManagerController from "./trilhas_manager_controller"
import AnalyticsController     from "./analytics_controller"
import UserMenuController      from "./user_menu_controller"
import TaxonomySuggestionsController from "./taxonomy_suggestions_controller"
import TagsSelectorController  from "./tags_selector_controller"
import CategoriaSelectorController from "./categoria_selector_controller"
import CategoriaCreatorController from "./categoria_creator_controller"
import BuscaRapidaController     from "./busca_rapida_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

application.register("editor",         EditorController)
application.register("blocks-editor",  BlocksEditorController)
application.register("accordion",      AccordionController)
application.register("modal",          ModalController)
application.register("modal-link",     ModalLinkController)
application.register("sortable",       SortableController)
application.register("hierarchical-sortable", HierarchicalSortableController)
application.register("sidebar",        SidebarController)
application.register("sidebar-toggle", SidebarToggleController)
application.register("sidebar-spacing", SidebarSpacingController)
application.register("sidebar-item-form", SidebarItemFormController)
application.register("mobile-sidebar", MobileSidebarController)
application.register("carrossel",      CarrosselController)
application.register("secao-form",    SecaoFormController)
application.register("trilha-modulo-selector", TrilhaModuloSelectorController)
application.register("trilhas-manager", TrilhasManagerController)
application.register("analytics",      AnalyticsController)
application.register("user-menu",      UserMenuController)
application.register("taxonomy-suggestions", TaxonomySuggestionsController)
application.register("tags-selector",  TagsSelectorController)
application.register("categoria-selector", CategoriaSelectorController)
application.register("categoria-creator", CategoriaCreatorController)
application.register("busca-rapida",     BuscaRapidaController)

export { application }
