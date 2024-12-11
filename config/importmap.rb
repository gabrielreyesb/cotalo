# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "controllers", to: "controllers/index.js", preload: true
pin "controllers/application", to: "controllers/application.js", preload: true
pin "controllers/turbo_frame_controller", to: "controllers/turbo_frame_controller.js", preload: true
