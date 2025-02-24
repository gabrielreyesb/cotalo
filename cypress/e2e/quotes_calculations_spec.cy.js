describe('Quote Calculations', () => {
  beforeEach(() => {
    cy.session('user-session', () => {
      cy.visit('/')
      cy.get('[name="user[email]"]').type('gabrielreyesb@gmail.com', { delay: 100 })
      cy.get('[name="user[password]"]').type('123456', { delay: 100 })
      cy.get('[name="commit"]').click()
      cy.url().should('not.include', '/sign_in')
    })
  })

  it('calculates quote values correctly', () => {
    cy.visit('/quotes/calculate')
    cy.viewport(1920, 1080)
    
    cy.log('--- Setting up initial values ---')
    cy.get('#quote_product_quantity').type('3000', { delay: 100 })
    cy.get('#quote_product_width').type('30', { delay: 100 })
    cy.get('#quote_product_length').type('20', { delay: 100 })

    cy.log('--- Testing Material Calculations ---')
    cy.log('Adding material with price $2.15/mt2')
    cy.get('#material-select').select('1')
    cy.get('button[data-action="click->quotes#addMaterial"]').click({ force: true })

    cy.log('Verifying material table values...')
    cy.get('[data-quotes-target="materialsTable"] tbody tr').first().within(() => {
      // Material name
      cy.get('td').eq(1).should('contain', 'Bond')
      
      // Price
      cy.get('td').eq(2).should('contain', '$2.15')
      
      // Width
      cy.get('td').eq(3).should('contain', '70.5 cm')
      
      // Length
      cy.get('td').eq(4).should('contain', '50.5 cm')
      
      // Pieces per material - try multiple approaches
      cy.get('td').eq(5).then($td => {
        cy.log('TD HTML:', $td.html())  // Log the HTML content
        cy.log('TD Text:', $td.text())  // Log the text content
        
        // Try getting value if it's an input
        const input = $td.find('input')
        if (input.length) {
          cy.wrap(input).invoke('val').then(val => {
            cy.log('Input value:', val)
            expect(val).to.equal('4')
          })
        } else {
          // If not an input, try text content
          const text = $td.text().trim()
          cy.log('TD trimmed text:', text)
          expect(text).to.equal('4')
        }
      })
      
      // Total sheets
      cy.get('td').eq(6).should('contain', '750')
      
      // Total mt2
      cy.get('td').eq(7).should('contain', '267.02')
      
      // Total price
      cy.get('td').eq(8).should('contain', '$574.09')
    })

    cy.log('--- Testing Process Calculations ---')
    cy.log('Adding process with price $120/mt2')
    cy.get('#process-select').select('1')
    cy.get('button[data-action="click->quotes#addProcess"]').click({ force: true })

    cy.log('Verifying process table values...')
    cy.get('[data-quotes-target="processes"] tbody tr').first().within(() => {
      
        cy.get('td').eq(4).should('contain', '$32,042.40')

      })

    cy.log('--- Testing Extras Calculations ---')
    cy.log('Adding extra with price $120/mt2')
    cy.get('#extra-select').select('1')
    cy.get('button[data-action="click->quotes#addExtra"]').click({ force: true })

    cy.log('Verifying extra table values...')
    cy.get('[data-quotes-target="extras"] tbody tr').first().within(() => {
        cy.get('td').eq(5).should('contain', '$400.00')
    })

    cy.log('--- Testing Final Calculations ---')
    
    // Subtotal
    cy.get('#subtotal-display').invoke('text').then(text => {
      cy.log('Subtotal:', text)
      expect(text.trim()).to.contain('$32,616.49')
    })
    
    // Waste (Merma)
    cy.get('#waste-price-display').invoke('text').then(text => {
      cy.log('Waste calculation (10%):', text)
      expect(text.trim()).to.contain('$3,261.65')
    })
    
    // Price per piece before margin
    cy.get('#price-per-piece-before-margin-display').invoke('text').then(text => {
      cy.log('Price per piece before margin:', text)
      expect(text.trim()).to.contain('$11.96')
    })

    // Margin value
    cy.get('#margin-price-display').invoke('text').then(text => {
      cy.log('Margin value (15%):', text)
      expect(text.trim()).to.contain('$5,381.72')
    })
    
    // Total quote value
    cy.get('#total-quote-value-display').invoke('text').then(text => {
      cy.log('Final quote value:', text)
      expect(text.trim()).to.equal('$41,259.86')
    })

    // Price per piece
    cy.get('#price-per-piece-display').invoke('text').then(text => {
      cy.log('Final price per piece:', text)
      expect(text.trim()).to.contain('$13.75')
    })
  })
}) 