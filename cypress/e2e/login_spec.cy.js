describe('Login', () => {
  it('successfully logs in', () => {
    cy.visit('/users/sign_in')
    
    cy.get('[name="user[email]"]').type('gabrielreyesb@gmail.com')
    cy.get('[name="user[password]"]').type('123456')
    cy.get('[name="commit"]').click()
    
    // Update the assertion to match your Spanish interface
    cy.contains('Iniciar sesión').should('not.exist')
    // Add an assertion for something that should appear after successful login
    // For example, if there's a dashboard or welcome message:
    // cy.contains('Bienvenido').should('be.visible')
  })
}) 