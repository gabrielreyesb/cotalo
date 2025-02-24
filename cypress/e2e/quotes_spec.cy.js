describe('Quotes', () => {
  beforeEach(() => {
    cy.session('user-session', () => {
      cy.visit('/')
      cy.get('[name="user[email]"]').type('gabrielreyesb@gmail.com', { delay: 100 })
      cy.get('[name="user[password]"]').type('123456', { delay: 100 })
      cy.get('[name="commit"]').click()
      cy.url().should('not.include', '/sign_in')
    })
  })

  it('creates a new quote successfully', () => {
    cy.visit('/quotes/calculate')
    cy.wait(2000)
    cy.viewport(1920, 1080)
    
    // Project Information
    cy.get('[name="quote[projects_name]"]').type('Proyecto de Prueba 1', { delay: 100 })
    cy.get('[name="quote[product_name]"]').type('Producto de Prueba 1', { delay: 100 })
    cy.get('[name="quote[customer_name]"]').type('Cliente de Prueba 1', { delay: 100 })
    cy.get('[name="quote[customer_organization]"]').type('Organización de Prueba', { delay: 100 })
    cy.get('[name="quote[customer_email]"]').type('cliente@ejemplo.com', { delay: 100 })
    cy.get('[name="quote[customer_phone]"]').type('1234567890', { delay: 100 })

    // Product Specifications
    cy.get('#quote_product_quantity').type('3000', { delay: 100 })
    cy.get('#quote_product_width').type('30', { delay: 100 })
    cy.get('#quote_product_length').type('20', { delay: 100 })
    cy.get('[name="quote[internal_measures]"]').type('10x15x20', { delay: 100 })

    // Materials Section
    cy.get('#material-select').select('1')
    cy.get('button[data-action="click->quotes#addMaterial"]').click({ force: true })
    cy.wait(2000)
    
    // Process Section
    cy.get('#process-select').select('1')
    cy.get('button[data-action="click->quotes#addProcess"]').click({ force: true })
    cy.wait(2000)

    // Extras Section
    cy.get('#extra-select').select('1')
    cy.get('button[data-action="click->quotes#addExtra"]').click({ force: true })
    cy.wait(2000)

    // Scroll to comments first to bring bottom area into view
    cy.get('[name="quote[comments]"]')
      .scrollIntoView()
      .should('be.visible')
    
    // Find and click the submit button - this is the last step
    cy.get('input[type="submit"][value="Guardar cotización"]')
      .scrollIntoView()
      .should('be.visible')
      .click()
  })
})