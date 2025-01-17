import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["processes", "extras", "openIcon", "closeIcon", 
                   "productsPerSheet", "sheetsNeeded", 
                   "materialTotalPrice", "materialSquareMeters",
                   "materialsTable", "materialsSubtotal",
                   "includeExtras", "includeExtrasHidden"]; 

  connect() {
    this.newProcessId = 0; 
    this.newExtraId = 0;
    this.manualMaterialId = document.getElementById('manual-material-config').dataset.manualMaterialId;
    
    // Initialize all subtotals if there are existing items
    if (this.hasMaterialsSubtotalTarget) {
      this.updateMaterialsSubtotal();
    }
    if (this.hasProcessesTarget) {
      this.updateProcessesSubtotal();
    }
    if (this.hasExtrasTarget) {
      this.updateExtrasSubtotal();
    }
    
    // Get quote ID from hidden field
    const quoteIdField = document.querySelector('input[name="quote_id"]');
    if (quoteIdField && quoteIdField.value) {
      const quoteId = quoteIdField.value;
      console.log('Loading quote:', quoteId);
      const jsonUrl = `/quotes/${quoteId}.json`;
      console.log('Fetching from:', jsonUrl);
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      fetch(jsonUrl, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfToken
        },
        credentials: 'same-origin'
      })
        .then(response => {
          console.log('Response status:', response.status);
          console.log('Response headers:', response.headers);
          if (response.status === 500) {
            return response.text().then(text => {
              console.error('Server error response:', text);
              throw new Error(`HTTP error! status: ${response.status}`);
            });
          }
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.json();
        })
        .then(data => {
          console.log('Quote data:', data);
          // Initialize arrays if they don't exist
          data.quote_materials = data.quote_materials || [];
          data.quote_processes = data.quote_processes || [];
          data.quote_extras = data.quote_extras || [];
          
          this.quote = data;
          console.log('About to load existing data with:', this.quote);
          this.loadExistingData(data);
        })
        .catch(error => {
          console.error('Error loading quote:', error);
          console.error('Error details:', error.message);
          if (error.response) {
            error.response.text().then(text => {
              console.error('Response text:', text);
            });
          }
        });
    }
  }

  loadExistingData(data) {
    console.log('Loading existing data...');
    
    // Basic quote information
    document.querySelector('input[name="quote[projects_name]"]').value = data.projects_name || '';
    document.querySelector('input[name="quote[product_name]"]').value = data.product_name || '';
    document.querySelector('input[name="quote[customer_name]"]').value = data.customer_name || '';
    document.querySelector('input[name="quote[customer_organization]"]').value = data.customer_organization || '';
    document.querySelector('input[name="quote[customer_email]"]').value = data.customer_email || '';
    document.querySelector('input[name="quote[product_quantity]"]').value = data.product_quantity || '';
    document.querySelector('input[name="quote[product_width]"]').value = data.product_width || '';
    document.querySelector('input[name="quote[product_length]"]').value = data.product_length || '';
    
    // Pricing information
    document.querySelector('input[name="quote[subtotal]"]').value = data.subtotal || '';
    document.querySelector('input[name="quote[waste_price]"]').value = data.waste_price || '';
    document.querySelector('input[name="quote[margin_price]"]').value = data.margin_price || '';
    document.querySelector('input[name="quote[total_quote_value]"]').value = data.total_quote_value || '';
    document.querySelector('input[name="quote[product_value_per_piece]"]').value = data.product_value_per_piece || '';
    
    // Percentages
    document.querySelector('input[name="quote[waste_percentage]"]').value = data.waste_percentage || '';
    document.querySelector('input[name="quote[margin_percentage]"]').value = data.margin_percentage || '';
    
    // Comments
    const commentsField = document.querySelector('textarea[name="quote[comments]"]');
    if (commentsField) {
      commentsField.value = data.comments || '';
    }

    const materialsTable = this.materialsTableTarget;
    const processesTable = this.processesTarget;
    const extrasTable = this.extrasTarget;
    // Clear existing rows
    materialsTable.querySelector('tbody').innerHTML = '';
    processesTable.querySelector('tbody').innerHTML = '';
    extrasTable.querySelector('tbody').innerHTML = '';

    // Load materials
    data.quote_materials.forEach(material => {
      const row = document.createElement('tr');
      row.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeMaterial">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td style="text-align: left !important">${material.material.description}</td>
          <td style="text-align: right !important">${material.products_per_sheet}</td>
          <td style="text-align: right !important">${material.sheets_needed}</td>
          <td style="text-align: right !important">${material.square_meters}</td>
          <td style="text-align: right !important">$${material.total_price.toFixed(2)}</td>`;
      materialsTable.querySelector('tbody').appendChild(row);
      
      // Debug: Check applied styles
      setTimeout(() => {
        const cells = row.querySelectorAll('td');
        cells.forEach((cell, index) => {
          console.log(`Cell ${index} computed style:`, window.getComputedStyle(cell).textAlign);
        });
      }, 100);
    });

    // Load processes
    console.log('Starting to load processes:', data.quote_processes);
    data.quote_processes.forEach(process => {
      console.log('Processing process:', process);
      const row = document.createElement('tr');
      console.log('Creating row for process:', process.manufacturing_process.name);
      row.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeProcess">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td style="text-align: left !important">${process.manufacturing_process.name} - ${process.manufacturing_process.description}</td>
          <td style="text-align: right !important" class="process-price-total">$${process.price.toFixed(2)}</td>
      `;
      console.log('Row HTML created:', row.innerHTML);
      processesTable.querySelector('tbody').appendChild(row);
      console.log('Process table after adding row:', processesTable.outerHTML);
      console.log('Process price elements in table:', processesTable.querySelectorAll('.process-price-total').length);
    });

    // Load extras
    data.quote_extras.forEach(extra => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td class="text-center align-middle">
          <button type="button" 
                  class="btn btn-sm btn-link text-danger"
                  data-action="click->quotes#removeExtra">
            <i class="fas fa-trash"></i>
          </button>
        </td>
        <td style="text-align: left !important">${extra.extra.description}</td>
        <td style="text-align: right !important">${extra.quantity}</td>
        <td style="text-align: right !important" class="extra-price-total">$${extra.quantity * extra.extra.price.toFixed(2)}</td>
      `;
      
      // Add the necessary hidden fields separately
      const hiddenFields = document.createElement('div');
      hiddenFields.innerHTML = `
        <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][extra_id]" value="${extra.extra_id}">
        <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][quantity]" value="${extra.quantity}">
      `;
      row.appendChild(hiddenFields);

      extrasTable.querySelector('tbody').appendChild(row);
    });

    this.updateMaterialsSubtotal();
    this.updateProcessesSubtotal();
    this.updateExtrasSubtotal();
  }

  updateMaterialsSubtotal() {
    let subtotal = 0;
    const priceElements = this.materialsTableTarget.querySelectorAll('td:nth-child(5)');
    priceElements.forEach(el => {
      const row = el.closest('tr');
      if (row && row.style.display !== 'none') {
        const priceText = el.textContent.trim();
        const price = parseFloat(priceText.replace(/[$,]/g, '')) || 0;
        subtotal += price;
      }
    });
    this.materialsSubtotalTarget.textContent = `$${subtotal.toFixed(2)}`;
  }

  updateProcessesSubtotal() {
    let subtotal = 0;
    const priceElements = this.processesTarget.querySelectorAll('.process-price-total');
    
    priceElements.forEach(el => {
      const row = el.closest('tr');
      if (row && row.style.display !== 'none') {
        const price = parseFloat(el.textContent.replace(/[$,]/g, '')) || 0;
        subtotal += price;
      }
    });
    
    const subtotalElement = document.getElementById('processes-subtotal');
    if (subtotalElement) {
      subtotalElement.textContent = `$${subtotal.toFixed(2)}`;
    }
  }

  updateExtrasSubtotal() {
    let subtotal = 0;
    const priceElements = this.extrasTarget.querySelectorAll('.extra-price-total');

    priceElements.forEach(el => {
      const row = el.closest('tr');
      if (row && row.style.display !== 'none') {
        const price = parseFloat(el.textContent.replace(/[$,]/g, '')) || 0;
        subtotal += price;
      }
    });
    
    const subtotalElement = document.getElementById('extras-subtotal');
    if (subtotalElement) {
      subtotalElement.textContent = `$${subtotal.toFixed(2)}`;
    }
  }

  addProcess(event) {
    event.preventDefault();
    console.log('Adding new process...');

    const selectElement = document.getElementById('quote_manufacturing_process_id');
    const priceInput = document.getElementById('manufacturing_process_price_display');

    if (selectElement) { 
      const selectedOption = selectElement.selectedOptions[0];

      if (selectedOption) {        
        const processId = selectedOption.value;
        const processName = selectedOption.text.split(' - ')[0];
        const processDescription = selectedOption.text.split(' - ')[1];
        const processPrice = parseFloat(priceInput.value);
        const processUnit = selectedOption.getAttribute('data-unit');
          
        console.log('Process data:', {
          processId,
          processName,
          processDescription,
          processPrice,
          processUnit
        });

        // Get values from the material table row
        const materialRow = this.materialsTableTarget.querySelector('tbody tr');
        if (!materialRow) {
          alert('Por favor agregue un material primero');
          return;
        }

        const materialPieces = parseInt(materialRow.children[2].textContent) || 0;
        const squareMeters = parseFloat(materialRow.children[3].textContent) || 0;

        let calculatedPrice = 0;
        if (processUnit === "pliego") {
          calculatedPrice = processPrice * materialPieces;
        } else if (processUnit === "mt2" || processUnit === "m2") {
          calculatedPrice = processPrice * squareMeters;
        } else {
          console.error("Unknown process unit:", processUnit);
          return;
        }

        console.log('Calculated values:', {
          materialPieces,
          squareMeters,
          calculatedPrice
        });

        const newRow = document.createElement('tr');
        newRow.dataset.newProcess = "true";
        
        newRow.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeProcess">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td style="text-align: left !important">${processName} - ${processDescription}</td>
          <td style="text-align: right !important" class="process-price-total">$${calculatedPrice.toFixed(2)}</td>
          <input type="hidden" name="quote[quote_processes_attributes][][manufacturing_process_id]" value="${processId}">
          <input type="hidden" name="quote[quote_processes_attributes][][price]" value="${calculatedPrice}">
        `;

        console.log('New row HTML:', newRow.innerHTML);
        console.log('Hidden fields added:', newRow.querySelectorAll('input[type="hidden"]').length);

        // Append the new row to the table body
        this.processesTarget.querySelector('tbody').appendChild(newRow);
        console.log('Process row added, updating subtotal...');

        // Update processes subtotal
        this.updateProcessesSubtotal();

        // Clear the selection and price display
        selectElement.value = '';
        priceInput.value = '';
        document.getElementById('manufacturing_process_unit_display').textContent = '';

        // Increment the counter
        this.newProcessId++;
      }
    }
  }

  removeProcess(event) {
    event.preventDefault();
    const row = event.target.closest('tr');
    if (row) {
      // Add _destroy field if it's an existing process
      const processIdInput = row.querySelector('input[name*="quote_processes_attributes"][name*="[id]"]');
      const processIndex = processIdInput?.name.match(/quote\[quote_processes_attributes\]\[(\d+)\]/)?.[1];
      if (processIndex) {
        console.log('Marking process for deletion:', processIndex);
        const destroyField = document.createElement('input');
        destroyField.type = 'hidden';
        destroyField.name = `quote[quote_processes_attributes][${processIndex}][_destroy]`;
        destroyField.value = '1';
        console.log('Adding destroy field:', destroyField.name, destroyField.value);
        row.appendChild(destroyField);
        row.style.display = 'none';
      } else {
        row.remove();
      }
      this.updateProcessesSubtotal();
      this.calculateTotals();
    }
  }

  showManufactureProcessInfo(event) {
    const selectedOption = event.target.selectedOptions[0];
    const unitDisplay = document.getElementById('manufacturing_process_unit_display');
    const priceDisplay = document.getElementById('manufacturing_process_price_display');
    
    if (selectedOption && selectedOption.value) {
      const unit = selectedOption.getAttribute('data-unit');
      const price = selectedOption.getAttribute('data-price');
      
      unitDisplay.textContent = unit;
      priceDisplay.value = price;
    } else {
      unitDisplay.textContent = '';
      priceDisplay.value = '';
    }
  }

  addExtra(event) {
    event.preventDefault();
    console.log('Adding new extra...');

    const selectElement = document.getElementById('quote_extra_id');
    const priceInput = document.getElementById('extra_price_display');
    const quantityInput = document.getElementById('quantity');

    if (selectElement && priceInput && quantityInput) {
      const selectedOption = selectElement.selectedOptions[0];

      if (selectedOption) {
        const extraId = selectedOption.value;
        const extraDescription = selectedOption.text;
        const extraPrice = parseFloat(priceInput.value);
        const extraQuantity = parseInt(quantityInput.value, 10);
        const totalPrice = extraPrice * extraQuantity;

        // Create a new row for the extra
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeExtra">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td style="text-align: left !important">${extraDescription}</td>
          <td style="text-align: right !important">${extraQuantity}</td>
          <td style="text-align: right !important" class="extra-price-total">$${totalPrice.toFixed(2)}</td>
        `;

        // Add hidden fields for form data
        const hiddenFields = document.createElement('div');
        hiddenFields.innerHTML = `
          <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][extra_id]" value="${extraId}">
          <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][quantity]" value="${extraQuantity}">
        `;
        newRow.appendChild(hiddenFields);

        const tbody = this.extrasTarget.querySelector('tbody');
        tbody.appendChild(newRow);
        console.log('Extra row added, updating subtotal...');
        
        this.newExtraId++;
        this.updateExtrasSubtotal();

        // Reset inputs
        selectElement.value = '';
        priceInput.value = '';
        quantityInput.value = '1';
        const unitDisplay = document.getElementById('extra_unit_display');
        if (unitDisplay) unitDisplay.textContent = '';
      }
    }
  }

  removeExtra(event) {
    event.preventDefault();
    const row = event.target.closest('tr');
    if (row) {
      // Add _destroy field if it's an existing extra
      const extraId = row.querySelector('input[name*="[id]"]')?.value;
      if (extraId) {
        const destroyField = document.createElement('input');
        destroyField.type = 'hidden';
        destroyField.name = `quote[quote_extras_attributes][${extraId}][_destroy]`;
        destroyField.value = '1';
        row.appendChild(destroyField);
        row.style.display = 'none';
      } else {
        row.remove();
      }
      this.updateExtrasSubtotal();
      this.calculateTotals();
    }
  }

  showExtraInfo(event) {
    const selectElement = event.target; 
    const priceDisplay = selectElement.parentNode.querySelector('input[type="number"]');
    const price = selectElement.options[selectElement.selectedIndex].dataset.price;
    const unit = selectElement.options[selectElement.selectedIndex].dataset.unit;
  
    if (priceDisplay) {
      priceDisplay.value = parseFloat(price).toFixed(2);
    } else {
      console.error("Price display element not found for extra.");
    }
    
    // The following lines should be inside the if(priceDisplay) block
    const extraPriceDisplay = document.getElementById('extra_price_display'); 
    if (extraPriceDisplay) {
      extraPriceDisplay.textContent = `$${parseFloat(price).toFixed(2)}`; // Use price here
    }
  
    const extraUnitDisplay = document.getElementById('extra_unit_display');
    if (extraUnitDisplay) {
      extraUnitDisplay.textContent = unit; 
    }
  }
  
  calculateTotals(event) {
    // Only prevent default if event exists (i.e., button click)
    if (event) {
      event.preventDefault();
    }

    // Get materials subtotal
    const materialsSubtotalText = this.materialsSubtotalTarget.textContent;
    const materialsSubtotal = parseFloat(materialsSubtotalText.replace(/[$,]/g, '')) || 0;
    
    // Get processes subtotal
    const processesSubtotalText = document.getElementById('processes-subtotal').textContent;
    const processesSubtotal = parseFloat(processesSubtotalText.replace(/[$,]/g, '')) || 0;

    // Get extras subtotal if the target exists and is checked
    let extrasSubtotal = 0;
    if (this.hasIncludeExtrasTarget && this.includeExtrasTarget.checked) {
      const extrasSubtotalText = document.getElementById('extras-subtotal').textContent;
      extrasSubtotal = parseFloat(extrasSubtotalText.replace(/[$,]/g, '')) || 0;
      if (this.hasIncludeExtrasHiddenTarget) {
        this.includeExtrasHiddenTarget.value = "true";
      }
    } else if (this.hasIncludeExtrasHiddenTarget) {
      this.includeExtrasHiddenTarget.value = "false";
    }
    
    // Calculate subtotal
    const subtotal = materialsSubtotal + processesSubtotal + extrasSubtotal;

    // Calculate waste and margin
    const wastePercentage = parseFloat(document.getElementById('waste').value) || 0;
    const marginPercentage = parseFloat(document.getElementById('margin').value) || 0;
    
    const wasteAmount = (subtotal * wastePercentage) / 100;
    const marginAmount = (subtotal * marginPercentage) / 100;
    
    // Calculate final total
    const total = subtotal + wasteAmount + marginAmount;

    // Get product quantity for price per piece
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value) || 0;
    const pricePerPiece = productQuantity > 0 ? total / productQuantity : 0;

    // Update form fields with formatted values
    document.getElementById('quote_subtotal').value = subtotal.toFixed(2);
    document.getElementById('quote_waste_price').value = wasteAmount.toFixed(2);
    document.getElementById('quote_margin_price').value = marginAmount.toFixed(2);
    document.getElementById('total-quote-value').value = total.toFixed(2);
    document.getElementById('quote_product_value_per_piece').value = pricePerPiece.toFixed(2);
    
    // Also update the displayed subtotals
    this.materialsSubtotalTarget.textContent = `$${materialsSubtotal.toFixed(2)}`;
    document.getElementById('processes-subtotal').textContent = `$${processesSubtotal.toFixed(2)}`;
    if (this.hasIncludeExtrasTarget && this.includeExtrasTarget.checked) {
      document.getElementById('extras-subtotal').textContent = `$${extrasSubtotal.toFixed(2)}`;
    }
  }

  searchCustomer(event) {
    event.preventDefault();
    const customerName = document.getElementById('quote_customer_name').value;
    const organizationField = document.getElementById('quote_customer_organization');
    const emailField = document.getElementById('quote_customer_email');

    // Create or get the select element
    let organizationSelect = document.getElementById('organization_select');
    if (!organizationSelect) {
      organizationSelect = document.createElement('select');
      organizationSelect.id = 'organization_select';
      organizationSelect.className = 'form-control';
      organizationField.parentNode.insertBefore(organizationSelect, organizationField);
      organizationField.style.display = 'none';
    }

    // Store the results globally to access them when selection changes
    this.searchResults = [];

    console.log('Searching for customer:', customerName);

    fetch('/quotes/search_customer', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({
        quote: {
          customer_name: customerName
        }
      })
    })
    .then(response => {
      console.log('Response status:', response.status);
      if (!response.ok) {
        console.log('Response not OK, getting text...');
        return response.text().then(text => {
          console.log('Error response text:', text);
          throw new Error(`HTTP error! status: ${response.status}`);
        });
      }
      return response.json();
    })
    .then(data => {
      console.log('Received data:', data);
      if (data.results && data.results.length > 0) {
        this.searchResults = data.results;
        
        // Clear and populate the select
        organizationSelect.innerHTML = '<option value="">Seleccione una organización</option>';
        
        data.results.forEach((result, index) => {
          const option = document.createElement('option');
          option.value = index;
          option.textContent = `${result.name} - ${result.organization || 'Sin organización'}`;
          organizationSelect.appendChild(option);
        });

        // Add change event listener
        organizationSelect.onchange = (e) => {
          const selectedResult = this.searchResults[e.target.value];
          if (selectedResult) {
            organizationField.value = selectedResult.organization || '';
            emailField.value = selectedResult.email || '';
          }
        };

      } else {
        alert('No se encontraron resultados en Pipedrive');
      }
    })
    .catch(error => {
      console.error('Detailed error:', error);
      console.error('Error:', error);
      alert('Error al buscar en Pipedrive. Por favor intente nuevamente.');
    });
  }

  clearCustomerInfo() {
    const customerInfoDiv = document.getElementById('customer_info'); 
    if (customerInfoDiv) {
      customerInfoDiv.innerHTML = '';
    }
  }
  
  toggleManualMaterial(event) {
    event.preventDefault();
    const form = document.getElementById('manualMaterialForm');
    form.style.display = form.style.display === 'none' ? 'block' : 'none';
  }

  addManualMaterial(event) {
    event.preventDefault();
    
    const description = document.getElementById('manual_material_description').value;
    const unitId = document.getElementById('manual_material_unit').value;
    const price = parseFloat(document.getElementById('manual_material_price').value);
    const width = parseFloat(document.getElementById('manual_material_width').value);
    const length = parseFloat(document.getElementById('manual_material_length').value);
    
    if (!description || !unitId || !price || !width || !length) {
      alert('Por favor complete todos los campos');
      return;
    }

    // Ensure width and length are valid numbers
    if (isNaN(width) || width <= 0 || isNaN(length) || length <= 0) {
      alert('El ancho y largo deben ser números mayores que 0');
      return;
    }

    // Calculate values for manual material
    const productWidth = parseFloat(document.getElementById('quote_product_width').value);
    const productLength = parseFloat(document.getElementById('quote_product_length').value);
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);
    
    const productsPerSheet = this.calculateProductsPerSheet({ width, length }, productWidth, productLength);
    const sheetsNeeded = this.calculateSheetsNeeded(productsPerSheet, productQuantity);
    const squareMeters = this.calculateSquareMeters({ width, length }, sheetsNeeded);
    const totalPrice = price * squareMeters;

    // Add to table with manual flag and placeholder material ID
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td style="text-align: left !important">${description}</td>
      <td style="text-align: right !important">${productsPerSheet}</td>
      <td style="text-align: right !important">${sheetsNeeded}</td>
      <td style="text-align: right !important">${squareMeters.toFixed(2)}</td>
      <td style="text-align: right !important">$${totalPrice.toFixed(2)}</td>
      <td>
        <button type="button" class="btn btn-sm btn-outline-danger" data-action="click->quotes#removeMaterial">
          Eliminar
        </button>
        <input type="hidden" name="quote[quote_materials_attributes][][material_id]" value="${this.manualMaterialId}">
        <input type="hidden" name="quote[quote_materials_attributes][][manual_description]" value="${description}">
        <input type="hidden" name="quote[quote_materials_attributes][][manual_unit]" value="${unitId}">
        <input type="hidden" name="quote[quote_materials_attributes][][manual_width]" value="${width}">
        <input type="hidden" name="quote[quote_materials_attributes][][manual_length]" value="${length}">
        <input type="hidden" name="quote[quote_materials_attributes][][products_per_sheet]" value="${productsPerSheet}">
        <input type="hidden" name="quote[quote_materials_attributes][][sheets_needed]" value="${sheetsNeeded}">
        <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters}">
        <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice}">
      </td>
    `;
    
    this.materialsTableTarget.querySelector('tbody').appendChild(tr);
    this.updateMaterialsSubtotal();
    
    // Clear form
    document.getElementById('manual_material_description').value = '';
    document.getElementById('manual_material_unit').value = '';
    document.getElementById('manual_material_width').value = '';
    document.getElementById('manual_material_length').value = '';
    document.getElementById('manual_material_price').value = '';
    
    // Hide the form
    document.getElementById('manualMaterialForm').style.display = 'none';
  }

  addMaterialToList(event) {
    event.preventDefault();
    
    const materialSelect = document.getElementById('material-select');
    const priceInput = document.getElementById('additional_material_price_display');
    
    if (materialSelect && priceInput) {
      const selectedOption = materialSelect.selectedOptions[0];
      
      if (selectedOption) {
        const materialId = selectedOption.value;
        const materialDescription = selectedOption.text;
        const materialPrice = parseFloat(priceInput.value);
        
        // Get product dimensions and quantity
        const productWidth = parseFloat(document.getElementById('quote_product_width').value);
        const productLength = parseFloat(document.getElementById('quote_product_length').value);
        const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);
        
        // Calculate values
        const productsPerSheet = Math.floor((90 * 70) / (productWidth * productLength));
        const sheetsNeeded = Math.ceil(productQuantity / productsPerSheet);
        const squareMeters = (sheetsNeeded * 90 * 70) / 10000;
        const totalPrice = materialPrice * squareMeters;
        
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeMaterial">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td style="text-align: left !important">${materialDescription}</td>
          <td style="text-align: right !important">${productsPerSheet}</td>
          <td style="text-align: right !important">${sheetsNeeded}</td>
          <td style="text-align: right !important">${squareMeters.toFixed(2)}</td>
          <td style="text-align: right !important">$${totalPrice.toFixed(2)}</td>
        `;
        
        // Add hidden fields for form submission
        const hiddenFields = document.createElement('div');
        hiddenFields.innerHTML = `
          <input type="hidden" name="quote[quote_materials_attributes][][material_id]" value="${materialId}">
          <input type="hidden" name="quote[quote_materials_attributes][][products_per_sheet]" value="${productsPerSheet}">
          <input type="hidden" name="quote[quote_materials_attributes][][sheets_needed]" value="${sheetsNeeded}">
          <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters}">
          <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice.toFixed(2)}">
        `;
        newRow.appendChild(hiddenFields);
        
        const tbody = this.materialsTableTarget.querySelector('tbody');
        tbody.appendChild(newRow);
        
        this.updateMaterialsSubtotal();
        
        // Reset the form
        materialSelect.value = '';
        priceInput.value = '';
        document.getElementById('additional_material_unit_display').textContent = '';
      }
    }
  }

  calculateProductsPerSheet(material, productWidth, productLength) {
    const productsInWidth = Math.floor(material.width / productWidth);
    const productsInLength = Math.floor(material.length / productLength);
    return productsInWidth * productsInLength;
  }

  calculateSheetsNeeded(productsPerSheet, productQuantity) {
    return Math.ceil(productQuantity / productsPerSheet);
  }

  calculateSquareMeters(material, sheetsNeeded) {
    return (material.width * material.length * sheetsNeeded) / 10000.0;
  }

  addMaterialToTable(material, productsPerSheet, sheetsNeeded, squareMeters, totalPrice) {
    const tbody = this.materialsTableTarget.querySelector('tbody');
    const tr = document.createElement('tr');
    
    tr.innerHTML = `
      <td>${material.description}</td>
      <td class="text-end align-middle">${productsPerSheet}</td>
      <td class="text-end align-middle">${sheetsNeeded}</td>
      <td class="text-end align-middle">${squareMeters.toFixed(2)}</td>
      <td class="text-end align-middle">$${totalPrice.toFixed(2)}</td>
      <td class="text-center">
        <button type="button"
                class="btn btn-sm btn-link text-danger"
                data-action="click->quotes#removeMaterial">
          <i class="fas fa-trash"></i>
        </button>
        <input type="hidden" name="quote[quote_materials_attributes][][material_id]" value="${material.id}">
        <input type="hidden" name="quote[quote_materials_attributes][][products_per_sheet]" value="${productsPerSheet}">
        <input type="hidden" name="quote[quote_materials_attributes][][sheets_needed]" value="${sheetsNeeded}">
        <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters}">
        <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice}">
      </td>
    `;
    
    tbody.appendChild(tr);
  }

  removeMaterial(event) {
    event.preventDefault();
    
    const row = event.target.closest('tr');
    if (row) {
      // Add _destroy field if it's an existing material
      const materialId = row.querySelector('input[name*="[id]"]')?.value;
      if (materialId) {
        const destroyField = document.createElement('input');
        destroyField.type = 'hidden';
        destroyField.name = `quote[quote_materials_attributes][${materialId}][_destroy]`;
        destroyField.value = '1';
        row.appendChild(destroyField);
        row.style.display = 'none';
      } else {
        row.remove();
      }
      this.updateMaterialsSubtotal();
      this.calculateTotals();
    }
  }

  showAdditionalMaterialInfo(event) {
    const selectedOption = event.target.selectedOptions[0];
    const unitDisplay = document.getElementById('additional_material_unit_display');
    const priceDisplay = document.getElementById('additional_material_price_display');
    
    if (selectedOption && selectedOption.value) {
      const unit = selectedOption.dataset.unit;
      const price = selectedOption.dataset.price;
      
      unitDisplay.textContent = unit || '';
      priceDisplay.value = price || '';
    } else {
      unitDisplay.textContent = '';
      priceDisplay.value = '';
    }
  }
}