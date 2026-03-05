# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "controllers/calculator_controller", to: "controllers/calculator_controller.js"
pin "controllers/drinks_controller", to: "controllers/drinks_controller.js"
pin "controllers/page_transition_controller", to: "controllers/page_transition_controller.js"
pin "controllers/shared/cart_dom", to: "controllers/shared/cart_dom.js"
pin "controllers/shared/cart_store", to: "controllers/shared/cart_store.js"
pin "controllers/shared/ui_helpers", to: "controllers/shared/ui_helpers.js"
