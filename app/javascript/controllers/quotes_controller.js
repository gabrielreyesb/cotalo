import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["processes", "extras", "openIcon", "closeIcon", 
                   "productsPerSheet", "sheetsNeeded", 
                   "materialTotalPrice", "materialSquareMeters",
                   "materialsTable", "materialsSubtotal"]; 

  connect() {
    this.newProcessId = 0; 
    this.newExtraId = 0;
    this.manualMaterialId = document.getElementById('manual-material-config').dataset.manualMaterialId;
  }

  addProcess(event) {
    event.preventDefault();

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

        const formattedPrice = calculatedPrice.toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2
        });

        const newRow = document.createElement('tr');
        newRow.dataset.newProcess = "true";
        newRow.innerHTML = `
          <td>
            <input type="hidden" name="quote[quote_processes_attributes][${this.newProcessId}][manufacturing_process_id]" value="${processId}">
            <input type="hidden" name="quote[quote_processes_attributes][${this.newProcessId}][price]" value="${calculatedPrice}">
            <span class="process-name">${processName}</span> - 
            <span class="process-description">${processDescription}</span>
          </td>
          <td class="text-end align-middle process-price-total" data-price-id="${this.newProcessId}">
            ${formattedPrice}
          </td>
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeProcess">
              <i class="fas fa-trash"></i>
            </button>
          </td>
        `;

        // Append the new row to the table body
        this.processesTarget.querySelector('tbody').appendChild(newRow);

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

  updateProcessesSubtotal() {
    const subtotalElement = document.getElementById('processes-subtotal');
    if (subtotalElement && this.processesTarget) {
      const prices = Array.from(this.processesTarget.querySelectorAll('.process-price-total'))
        .map(td => {
          // Remove commas and parse as float
          return parseFloat(td.textContent.replace(/,/g, '')) || 0;
        });
      
      const total = prices.reduce((sum, price) => sum + price, 0);
      
      // Format without currency symbol, just number with commas and 2 decimals
      subtotalElement.textContent = total.toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    }
  }

  removeProcess(event) {
    event.preventDefault();

    const row = event.target.closest('tr'); 
    if (row) {
      row.remove();
      this.updateProcessesSubtotal();
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

    // Get the select element directly
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

        // Create a new row for the extra
        const newRow = document.createElement('tr');
        newRow.dataset.newExtra = "true";
        newRow.innerHTML = `
          <td class="align-middle">
            <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][extra_id]" value="${extraId}">
            <input type="hidden" name="quote[quote_extras_attributes][${this.newExtraId}][quantity]" value="${extraQuantity}">
            <span class="extra-description">${extraDescription}</span>
            (<span class="extra-quantity">${extraQuantity}</span>)
          </td>
          <td class="text-end align-middle">
            <span class="extra-price-total">${(extraPrice * extraQuantity).toFixed(2)}</span>
          </td>
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger" 
                    data-action="click->quotes#removeExtra">
              <i class="fas fa-trash"></i>
            </button>
          </td>
        `;

        const tbody = this.extrasTarget.querySelector('tbody');
        tbody.appendChild(newRow);
        
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

  updateExtrasSubtotal() {
    const subtotalElement = document.getElementById('extras-subtotal');
    if (subtotalElement && this.extrasTarget) {
      const prices = Array.from(this.extrasTarget.querySelectorAll('.extra-price-total'))
        .map(span => parseFloat(span.textContent.replace(/,/g, '')) || 0);
      
      const total = prices.reduce((sum, price) => sum + price, 0);
      
      // Format the subtotal with thousands separator and 2 decimals
      subtotalElement.textContent = total.toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    }
  }

  removeExtra(event) {
    event.preventDefault();
  
    const row = event.target.closest('tr');
    if (row) {
      row.remove();
      this.updateExtrasSubtotal();
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
    event.preventDefault();

    // Get materials subtotal
    const materialsSubtotalText = this.materialsSubtotalTarget.textContent;
    const materialsSubtotal = parseFloat(materialsSubtotalText.replace(/[$,]/g, '')) || 0;
    
    // Get processes subtotal
    const processesSubtotalText = document.getElementById('processes-subtotal').textContent;
    const processesSubtotal = parseFloat(processesSubtotalText.replace(/[$,]/g, '')) || 0;
    
    // Calculate subtotal
    const subtotal = materialsSubtotal + processesSubtotal;

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

    // Safely update all form fields
    const updates = [
      { id: 'quote_subtotal', value: subtotal.toFixed(2) },
      { id: 'quote_waste_price', value: wasteAmount.toFixed(2) },
      { id: 'quote_margin_price', value: marginAmount.toFixed(2) },
      { id: 'total-quote-value', value: total.toFixed(2) },
      { id: 'quote_product_value_per_piece', value: pricePerPiece.toFixed(2) }
    ];

    updates.forEach(({ id, value }) => {
      const element = document.getElementById(id);
      if (element) {
        element.value = value;
      } else {
        console.warn(`Element with id '${id}' not found`);
      }
    });
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
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      return response.json();
    })
    .then(data => {
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
      <td>${description}</td>
      <td class="text-end">${productsPerSheet}</td>
      <td class="text-end">${sheetsNeeded}</td>
      <td class="text-end">${squareMeters.toFixed(2)}</td>
      <td class="text-end">$${totalPrice.toFixed(2)}</td>
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

  async addMaterialToList(event) {
    event.preventDefault();
    
    const materialSelect = document.getElementById('material-select');
    const materialId = materialSelect.value;
    
    if (!materialId) {
      alert('Por favor seleccione un material');
      return;
    }

    try {
      const response = await fetch(`/materials/${materialId}.json`);
      const material = await response.json();
      
      // Get product dimensions
      const productWidth = parseFloat(document.getElementById('quote_product_width').value);
      const productLength = parseFloat(document.getElementById('quote_product_length').value);
      const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);

      if (!productWidth || !productLength || !productQuantity) {
        alert('Por favor ingrese las dimensiones y cantidad del producto');
        return;
      }

      // Calculate values
      const productsPerSheet = this.calculateProductsPerSheet(material, productWidth, productLength);
      const sheetsNeeded = this.calculateSheetsNeeded(productsPerSheet, productQuantity);
      const squareMeters = this.calculateSquareMeters(material, sheetsNeeded);
      const totalPrice = squareMeters * material.price;

      // Add to table
      this.addMaterialToTable(material, productsPerSheet, sheetsNeeded, squareMeters, totalPrice);
      
      // Update ONLY materials subtotal
      this.updateMaterialsSubtotal();
      
      // Clear selection
      materialSelect.value = '';

    } catch (error) {
      console.error('Error:', error);
      alert('Error al agregar el material');
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
      row.remove();
      this.updateMaterialsSubtotal();
    }
  }

  updateMaterialsSubtotal() {
    const rows = this.materialsTableTarget.querySelectorAll('tbody tr');
    let subtotal = 0;
    
    rows.forEach(row => {
      // Get price from the price column (5th column)
      const priceText = row.children[4].textContent;
      // Remove $ and any commas, then parse
      const price = parseFloat(priceText.replace(/[$,]/g, '')) || 0;
      subtotal += price;
    });
    
    // Format with $ and commas
    this.materialsSubtotalTarget.textContent = `$${subtotal.toFixed(2)}`;
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