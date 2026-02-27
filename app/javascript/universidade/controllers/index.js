import { Application } from "@hotwired/stimulus"
import EditorController        from "controllers/editor_controller"
import BlocksEditorController  from "controllers/blocks_editor_controller"
import AccordionController     from "controllers/accordion_controller"
import ModalController         from "controllers/modal_controller"
import ModalLinkController     from "controllers/modal_link_controller"
import SortableController      from "controllers/sortable_controller"
import HierarchicalSortableController from "controllers/hierarchical_sortable_controller"
import SidebarController       from "controllers/sidebar_controller"
import CarrosselController     from "controllers/carrossel_controller"
import SecaoFormController    from "controllers/secao_form_controller"

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
application.register("carrossel",      CarrosselController)
application.register("secao-form",    SecaoFormController)

export { application }
