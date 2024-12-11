# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "controllers/index", to: "controllers/index.js"
pin "controllers/application", to: "controllers/application.js"
pin "controllers/turbo_frame_controller", to: "controllers/turbo_frame_controller.js"
