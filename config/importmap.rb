# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Manually pin controllers
pin_all_from "app/javascript/controllers", under: "controllers"
pin "sweetalert2", to: "https://ga.jspm.io/npm:sweetalert2@11.7.3/dist/sweetalert2.all.js"
