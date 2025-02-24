const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1920,
    viewportHeight: 1080,
    defaultCommandTimeout: 10000,
    defaultCommandTimeout: 1000,
    slowTestThreshold: 1000,
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
}) 