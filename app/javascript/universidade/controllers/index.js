import { Application } from "@hotwired/stimulus"
import EditorController        from "controllers/editor_controller"
import BlocksEditorController  from "controllers/blocks_editor_controller"
import AccordionController     from "controllers/accordion_controller"
import ModalController         from "controllers/modal_controller"
import SortableController      from "controllers/sortable_controller"
import SidebarController       from "controllers/sidebar_controller"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application

application.register("editor",         EditorController)
application.register("blocks-editor",  BlocksEditorController)
application.register("accordion",      AccordionController)
application.register("modal",          ModalController)
application.register("sortable",       SortableController)
application.register("sidebar",        SidebarController)

export { application }
