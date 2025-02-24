// Add any custom commands you need here
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/users/sign_in')
  cy.get('[name="user[email]"]').type(email)
  cy.get('[name="user[password]"]').type(password)
  cy.get('[name="commit"]').click()
})

Cypress.Commands.add('createQuote', (quoteData = {}) => {
  const defaultData = {
    projectName: 'Proyecto de Prueba',
    productName: 'Producto de Prueba',
    clientEmail: 'cliente@ejemplo.com',
    quantity: '100',
    material: 'Cartón Corrugado',
    process: 'Troquelado',
    length: '20',
    width: '15',
    height: '10',
    needsPrinting: true
  }

  const data = { ...defaultData, ...quoteData }

  cy.contains('Nueva cotización').click()
  cy.get('[name="quote[project_name]"]').type(data.projectName)
  cy.get('[name="quote[product_name]"]').type(data.productName)
  cy.get('[name="quote[client_email]"]').type(data.clientEmail)
  cy.get('[name="quote[quantity]"]').type(data.quantity)
  // ... fill in other fields ...
}) 