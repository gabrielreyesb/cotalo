calculateProducts(event) {
    event.preventDefault();
    
    const materialSelect = document.getElementById('quote_material_id');
    const manualMaterialInput = document.getElementById('quote_manual_material');
    const manualMaterialWidth = document.getElementById('quote_manual_material_width');
    const manualMaterialLength = document.getElementById('quote_manual_material_length');
    const manualMaterialPrice = document.getElementById('manual_material_price');
    
    // Check if either material is selected or manual material is properly filled
    const hasSelectedMaterial = materialSelect && materialSelect.value;
    const hasManualMaterial = manualMaterialInput && 
                             manualMaterialInput.value && 
                             manualMaterialWidth && 
                             manualMaterialWidth.value && 
                             manualMaterialLength && 
                             manualMaterialLength.value &&
                             manualMaterialPrice &&
                             manualMaterialPrice.value;
    
    if (!hasSelectedMaterial && !hasManualMaterial) {
        alert("Por favor seleccione un material o complete la información del material manual");
        
        // Reset all calculation fields
        this.productsPerSheetTarget.value = 0;
        this.sheetsNeededTarget.value = 0;
        this.materialTotalPriceTarget.value = 0;
        this.materialSquareMetersTarget.value = 0;
        return;
    }
    
    let materialWidth, materialLength, materialPrice;

    if (hasSelectedMaterial) {
        const selectedOption = materialSelect.selectedOptions[0];
        materialWidth = parseFloat(selectedOption.getAttribute('data-width'));
        materialLength = parseFloat(selectedOption.getAttribute('data-length'));
        materialPrice = parseFloat(document.getElementById('material_price').value);
    } else {
        materialWidth = parseFloat(manualMaterialWidth.value);
        materialLength = parseFloat(manualMaterialLength.value);
        materialPrice = parseFloat(manualMaterialPrice.value);
    }

    // Get values directly from number inputs
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value) || 0;
    const productWidth = parseFloat(document.getElementById('quote_product_width').value) || 0;
    const productLength = parseFloat(document.getElementById('quote_product_length').value) || 0;

    const configMarginWidth = parseFloat(document.getElementById('config_margin_width').value) || 0;
    const configMarginLength = parseFloat(document.getElementById('config_margin_length').value) || 0;

    const finalProductWidth = productWidth + configMarginWidth;
    const finalProductLength = productLength + configMarginLength;

    if (finalProductWidth > materialWidth || finalProductLength > materialLength) {
      alert(`El producto es demasiado grande para el material seleccionado.
      \nTamaño del producto (con márgenes): ${finalProductWidth} x ${finalProductLength}
      \nTamaño del material: ${materialWidth} x ${materialLength}`);
      
      this.productsPerSheetTarget.value = 0;
      this.sheetsNeededTarget.value = 0;
      this.materialTotalPriceTarget.value = 0;
      this.materialSquareMetersTarget.value = 0;
      return;
    }

    const productsInWidth = Math.floor(materialWidth / finalProductWidth);
    const productsInLength = Math.floor(materialLength / finalProductLength);
    const totalProducts = productsInWidth * productsInLength;
    
    if (totalProducts <= 0) {
      alert("No es posible calcular el número de productos por pliego. Verifique las dimensiones.");
      return;
    }

    this.productsPerSheetTarget.value = totalProducts;

    const sheetsNeeded = Math.ceil(productQuantity / totalProducts); 
    this.sheetsNeededTarget.value = sheetsNeeded;

    const quoteValue = materialPrice * sheetsNeeded;
    this.materialTotalPriceTarget.value = quoteValue.toFixed(2);

    const squareMeters = (materialLength * materialWidth * sheetsNeeded) / 10000;
    this.materialSquareMetersTarget.value = squareMeters.toFixed(2);
  }

  reCalculateProducts(event) {
    event.preventDefault();
    
    // Get product dimensions
    const productWidth = parseFloat(document.getElementById('quote_product_width').value);
    const productLength = parseFloat(document.getElementById('quote_product_length').value);
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);

    if (!productWidth || !productLength || !productQuantity) {
      alert('Por favor ingrese las dimensiones y cantidad del producto');
      return;
    }

    // Recalculate materials
    this.recalculateMaterials();

    // Recalculate processes (existing code)
    const processRows = this.processesTarget.querySelectorAll('tr');
    processRows.forEach(row => {
      const priceInput = row.querySelector('input[type="number"]');
      if (priceInput) {
        this.updateProcessPrice(priceInput);
      }
    });

    // Recalculate extras (existing code)
    const extraRows = this.extrasTarget.querySelectorAll('tr');
    extraRows.forEach(row => {
      const quantityInput = row.querySelector('input[type="number"]');
      if (quantityInput) {
        this.updateExtraPrice(quantityInput);
      }
    });

    // Update totals
    this.calculateTotals();
  }


  createProcessField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_process", "g"); 
    const newProcessFields = this.processFieldsTemplate.replace(regexp, newId);
    return newProcessFields;
  }

  addProcessToList(processDescription, processPrice, processUnit, calculatedPrice) {
    const newRow = document.createElement('tr'); 
    const descriptionCell = document.createElement('td');
    
    descriptionCell.textContent = processDescription;
    newRow.appendChild(descriptionCell);

    const removeCell = document.createElement('td');
    const removeButton = document.createElement('button');
    removeButton.textContent = 'Eliminar';
    removeButton.classList.add('btn', 'btn-danger');
    removeButton.setAttribute('data-action', 'click->quotes#removeProcess');
    removeButton.addEventListener('click', (event) => {
      event.preventDefault();
      newRow.remove();
      this.updateProcessesSubtotal();
    });
    removeCell.appendChild(removeButton);
    removeCell.classList.add('text-center');
    newRow.appendChild(removeCell);

    const priceCell = document.createElement('td');
    priceCell.textContent = calculatedPrice.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
    priceCell.style.textAlign = 'right';
    newRow.appendChild(priceCell);

    this.processesTarget.querySelector('tbody').appendChild(newRow); 
  }

  addExtraToList(extraDescription, extraPrice, extraUnit, calculatedPrice) {
    const newRow = document.createElement('tr'); 
    const descriptionCell = document.createElement('td');
    
    descriptionCell.textContent = extraDescription;
    newRow.appendChild(descriptionCell);

    const removeCell = document.createElement('td');
    const removeButton = document.createElement('button');
    removeButton.textContent = 'Eliminar';
    removeButton.classList.add('btn', 'btn-danger');
    removeButton.setAttribute('data-action', 'click->quotes#removeExtra');
    removeButton.addEventListener('click', (event) => {
      event.preventDefault(); 
      newRow.remove();
      this.updateExtrasSubtotal();
    });
    removeCell.appendChild(removeButton);
    removeCell.classList.add('text-center');
    newRow.appendChild(removeCell);

    const priceCell = document.createElement('td');
    priceCell.textContent = calculatedPrice.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
    priceCell.style.textAlign = 'right';
    newRow.appendChild(priceCell);

    this.extrasTarget.querySelector('tbody').appendChild(newRow); 
  }

  showExtraDetails(event) {
    const selectedOption = event.target.selectedOptions[0];
    const extraPrice = parseFloat(selectedOption.dataset.price);
    const extraUnit = selectedOption.dataset.unit;

    const nestedFieldsDiv = event.target.closest('.nested-fields'); 
    const extraPriceDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="extraPrice"]');
    const extraUnitDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="extraUnit"]');
  
    if (extraPriceDisplay) {
      extraPriceDisplay.textContent = `$${extraPrice.toFixed(2)}`;
    }
  
    if (extraUnitDisplay) {
      extraUnitDisplay.textContent = extraUnit;
    }
  }

  createExtraField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_extra", "g"); 
    const newExtraFields = this.extraFieldsTemplate.replace(regexp, newId);
    return newExtraFields;
  }

  showMaterialPrice(event) {
    const selectedOption = event.target.selectedOptions[0];
    
    if (!selectedOption) {
      console.log("No option selected");
      return;
    }

    // Get elements
    const priceInput = document.getElementById('material_price');
    const unitDisplay = document.getElementById('material_unit_display');
    const unitIdInput = document.getElementById('quote_material_unit_id');
    const materialWidthInput = document.getElementById('material_width');
    const materialLengthInput = document.getElementById('material_length');

    // Update values
    if (priceInput) priceInput.value = selectedOption.getAttribute('data-price') || '';
    if (unitDisplay) unitDisplay.textContent = selectedOption.getAttribute('data-unit') || '';
    if (unitIdInput) unitIdInput.value = selectedOption.getAttribute('data-unit-id') || '';
    if (materialWidthInput) materialWidthInput.value = selectedOption.getAttribute('data-width') || '';
    if (materialLengthInput) materialLengthInput.value = selectedOption.getAttribute('data-length') || '';
  }

  get processFieldsTemplate() {
    return `
      <div class="nested-fields">
        <div class="form-group">
          <label for="quote_quote_processes_attributes_new_quote_process_manufacturing_process_id">Proceso:</label>
          <select class="form-control" name="quote[quote_processes_attributes][new_quote_process][manufacturing_process_id]" id="quote_quote_processes_attributes_new_quote_process_manufacturing_process_id"
                  data-action="change->quotes#showProcessDetails"> 
            <option value="">Select one</option>
            <% ManufacturingProcess.all.each do |process| %>
              <option value="<%= process.id %>" 
                      data-price="<%= process.price %>" 
                      data-unit="<%= process.unit.description %>"> 
                <%= process.description %>
              </option>
            <% end %>
          </select>
        </div>
        <div class="input-group-append">
          <span class="input-group-text" data-quotes-target="processPrice">$0.00</span>
          <span class="input-group-text ml-1" data-quotes-target="processUnit"></span>
        </div>
      </div>
      <button type="button" class="btn btn-danger" data-action="click->quotes#removeField">Eliminar</button>
    `.trim();
  }

  get toolingFieldsTemplate() {
    return `
      <div class="nested-fields">
        <div class="form-group">
          <label for="quote_quote_toolings_attributes_new_quote_tooling_tooling_id">Herramental:</label>
          <select class="form-control" name="quote[quote_toolings_attributes][new_quote_tooling][tooling_id]" id="quote_quote_toolings_attributes_new_quote_tooling_tooling_id"
                  data-action="change->quotes#showToolingDetails"> <%# Add data-action %>
            <option value="">Select one</option>
            <% Tooling.all.each do |tooling| %>
              <option value="<%= tooling.id %>" data-price="<%= tooling.price %>" data-unit="<%= tooling.unit.description %>"> <%# Add data attributes %>
                <%= tooling.description %> 
              </option>
            <% end %>
          </select>
        </div>
        <div class="input-group-append">
          <span class="input-group-text" data-quotes-target="toolingPrice">$0.00</span> <%# Add price display %>
          <span class="input-group-text ml-1" data-quotes-target="toolingUnit"></span> <%# Add unit display %>
        </div>
        <button type="button" class="btn btn-danger" data-action="click->quotes#removeField">Eliminar</button>
      </div>
    `.trim();
  }

  removeField(event) {
    event.preventDefault();
    const field = event.target.closest(".nested-fields");

    // Add the _destroy field
    const destroyField = document.createElement('input');
    destroyField.setAttribute('type', 'hidden');
    destroyField.setAttribute('name', this.getDestroyFieldName(event.target));
    destroyField.setAttribute('value', '1');
    field.appendChild(destroyField);

    // Hide the field instead of removing it immediately
    field.style.display = 'none'; 
  }

  getDestroyFieldName(target) {
    const fieldId = target.closest('div[id*=quote_quote_processes_attributes]').id || 
                    target.closest('div[id*=quote_quote_toolings_attributes]').id;
    if (fieldId) {
      return fieldId.replace(/quote_quote_processes_attributes_/, '') + '[_destroy]';
    } else {
      return ''; // Or handle the case where no fieldId is found
    }
  }

  updateWasteValue(event) {
    const wastePercentage = parseFloat(event.target.value);
    const subTotal = parseFloat(document.getElementById('sub-total-value').value);
  
    if (!isNaN(wastePercentage) && !isNaN(subTotal)) {
      const wasteValue = (wastePercentage / 100) * subTotal;
      document.getElementById('quote_waste_value').value = wasteValue.toFixed(2);
      this.calculateQuote();
    }
  }

  updateMarginValue(event) {
    const marginPercentage = parseFloat(event.target.value);
    const subTotal = parseFloat(document.getElementById('sub-total-value').value);
  
    if (!isNaN(marginPercentage) && !isNaN(subTotal)) {
      const marginValue = (marginPercentage / 100) * subTotal;
      document.getElementById('quote_margin_value').value = marginValue.toFixed(2);
      this.calculateQuote(); // Recalculate the quote
    }
  }

  updateManualMaterialUnit(event) {
    const selectedOption = event.target.selectedOptions[0];
    const manualMaterialUnitId = selectedOption.value;
  
    const unitIdField = document.getElementById('quote_manual_material_unit_id');
    if (unitIdField) {
      unitIdField.value = manualMaterialUnitId;
    }

  }

  updateHiddenField(event) {
    const hiddenField = document.getElementById('products-per-sheet-hidden');
    hiddenField.value = event.target.value;
  }

  getDimensionValue(fieldId) {
    const input = document.getElementById(fieldId);
    if (input) {
      return parseFloat(input.getAttribute('data-real-value')) || parseFloat(input.value.replace(/,/g, '')) || 0;
    }
    return 0;
  }

  formatProductsPerSheet(event) {
    const input = event.target;
    let value = input.value.replace(/[^\d]/g, '');  // Remove non-digits
    value = parseInt(value, 10) || 0;  // Convert to integer
    
    // Format with thousands separator
    input.value = value.toLocaleString('en-US');
    input.setAttribute('data-real-value', value.toString());
  }

  getProductsPerSheetValue() {
    const input = document.getElementById('products-per-sheet');
    if (input) {
      return parseInt(input.getAttribute('data-real-value')) || 0;
    }
    return 0;
  }

  handleSubmit(event) {
    // Add email validation
    const emailInput = document.getElementById('quote_customer_email');
    if (!emailInput || !emailInput.value.trim()) {
        event.preventDefault();
        alert("Por favor ingrese el correo electrónico del cliente antes de guardar la cotización");
        return false;
    }

    // Add validation for calculated values
    const productsPerSheet = parseFloat(document.getElementById('products-per-sheet').value) || 0;
    const sheetsNeeded = parseFloat(document.getElementById('sheets-needed').value) || 0;
    const materialTotalPrice = parseFloat(document.getElementById('material-total-price').value) || 0;
    const totalQuoteValue = parseFloat(document.getElementById('total-quote-value').value) || 0;

    if (productsPerSheet === 0 || sheetsNeeded === 0 || materialTotalPrice === 0 || totalQuoteValue === 0) {
        event.preventDefault();
        alert("Por favor calcule los productos y la cotización antes de guardar");
        return false;
    }

    // Get all the inputs that need to be cleaned
    const quantityInput = document.getElementById('quote_product_quantity');
    const totalQuoteInput = document.getElementById('total-quote-value');
    const wastePriceInput = document.getElementById('quote_waste_price');
    const marginPriceInput = document.getElementById('quote_margin_price');

    // Clean up the values by removing commas
    if (quantityInput) {
        quantityInput.value = quantityInput.value.replace(/,/g, '');
    }

    if (totalQuoteInput) {
        totalQuoteInput.value = totalQuoteInput.value.replace(/,/g, '');
    }

    if (wastePriceInput) {
        wastePriceInput.value = wastePriceInput.value.replace(/,/g, '');
    }

    if (marginPriceInput) {
        marginPriceInput.value = marginPriceInput.value.replace(/,/g, '');
    }

    return true;
  }

  recalculateMaterials() {
    const rows = this.materialsTableTarget.querySelectorAll('tbody tr');
    const productWidth = parseFloat(document.getElementById('quote_product_width').value);
    const productLength = parseFloat(document.getElementById('quote_product_length').value);
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);

    rows.forEach(async (row) => {
      const materialId = row.querySelector('input[name*="[material_id]"]').value;
      const response = await fetch(`/materials/${materialId}.json`);
      const material = await response.json();

      const productsPerSheet = this.calculateProductsPerSheet(material, productWidth, productLength);
      const sheetsNeeded = this.calculateSheetsNeeded(productsPerSheet, productQuantity);
      const squareMeters = this.calculateSquareMeters(material, sheetsNeeded);
      const totalPrice = squareMeters * material.price;

      // Update row values
      row.children[1].textContent = productsPerSheet;
      row.children[2].textContent = sheetsNeeded;
      row.children[3].textContent = squareMeters.toFixed(2);
      row.children[4].textContent = `$${totalPrice.toFixed(2)}`;

      // Update hidden inputs
      row.querySelector('input[name*="[products_per_sheet]"]').value = productsPerSheet;
      row.querySelector('input[name*="[sheets_needed]"]').value = sheetsNeeded;
      row.querySelector('input[name*="[square_meters]"]').value = squareMeters;
      row.querySelector('input[name*="[total_price]"]').value = totalPrice;
    });

    this.updateMaterialsSubtotal();
    this.calculateTotals();
  }

  showMaterialInfo(event) {
    const selectedOption = event.target.selectedOptions[0];
    const unitDisplay = document.getElementById('material_unit_display');
    const priceDisplay = document.getElementById('material_price');
    
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

  