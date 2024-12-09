import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["processes", "toolings", "openIcon", "closeIcon", 
                   "productsFit", "materialPieces", "materialPrice", "squareMeters"]; 

  connect() {
    this.newProcessId = 0; 
    this.newToolingId = 0; 
  }

  calculateProducts(event) {
    event.preventDefault();
    
    const materialSelect = document.getElementById('quote_material_id');
    const priceInput = document.getElementById('material_price');

    const manualMaterial = document.getElementById('quote_manual_material').value;
    const manualMaterialPrice = parseFloat(document.getElementById('manual_material_price').value);
    const manualMaterialWidth = parseFloat(document.getElementById('quote_manual_material_width').value); 
    const manualMaterialLength = parseFloat(document.getElementById('quote_manual_material_length').value);   
    
    let materialWidth, materialLength, materialPrice;

    if (manualMaterial !== "") {
      materialWidth = manualMaterialWidth;
      materialLength = manualMaterialLength;
      materialPrice = manualMaterialPrice;
    } else {
      if (materialSelect) {
        const selectedOption = materialSelect.selectedOptions[0];
  
        if (selectedOption) {
          materialWidth = parseFloat(selectedOption.getAttribute('data-width'));
          materialLength = parseFloat(selectedOption.getAttribute('data-length'));
          materialPrice = parseFloat(priceInput.value);
        } else {
          console.error("No material selected!");
          return;
        }
      } else {
        console.error("Material select element not found!");
        return;
      }
    }
  
    const productQuantity = parseFloat(document.getElementById('quote_product_pieces').value) || 0;
    const productWidth = parseFloat(document.getElementById('quote_product_width').value) || 0;
    const productLength = parseFloat(document.getElementById('quote_product_length').value) || 0;

    const configMarginWidth = parseFloat(document.getElementById('config_margin_width').value) || 0;
    const configMarginLength = parseFloat(document.getElementById('config_margin_length').value) || 0;

    const finalProductWidth = productWidth + configMarginWidth;
    const finalProductLength = productLength + configMarginLength;

    if (finalProductWidth <= 0 || finalProductLength <= 0 || materialWidth <= 0 || materialLength <= 0) {
      alert("Dimensiones inválidas. El producto no cabe en el material.");  
      const productsFitElement = document.getElementById('products-per-sheet'); 
      if (productsFitElement) {
        productsFitElement.value = 0;
      }
      return;
    }

    const productsInWidth = Math.floor(materialWidth / finalProductWidth);
    const productsInLength = Math.floor(materialLength / finalProductLength);
    const totalProducts = productsInWidth * productsInLength;
    document.getElementById('products-per-sheet').value = totalProducts;

    const sheetsNeeded = Math.ceil(productQuantity / totalProducts); 
    document.getElementById('sheets-needed').value = sheetsNeeded;

    const quoteValue = materialPrice * sheetsNeeded;
    const formattedQuoteValue = quoteValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
    document.getElementById('material-total-price').value = quoteValue; 

    const squareMeters = (materialLength * materialWidth * sheetsNeeded) / 10000;
    document.getElementById('material-square-meters').value = squareMeters;
  }

  reCalculateProducts(event) {
    event.preventDefault();
  
    try {  
      const materialSelect = document.getElementById('quote_material_id');
      const priceInput = document.getElementById('material_price').value;
      const productsPerSheetInput = document.getElementById('products-per-sheet').value; 
      const productQuantity = parseFloat(document.getElementById('quote_product_pieces').value);
      
      if (materialSelect && priceInput && productsPerSheetInput) {
        const selectedOption = materialSelect.selectedOptions[0];
        if (selectedOption) {
          const piecesNeeded = Math.ceil(productQuantity / productsPerSheetInput); 
          document.getElementById('sheets-needed').textContent = piecesNeeded;

          const materialPrice = parseFloat(piecesNeeded * priceInput);
          const formattedMaterialPrice = materialPrice.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
          document.getElementById('material-total-price').textContent = formattedMaterialPrice; 
      
          const materialWidth = parseFloat(selectedOption.getAttribute('data-width'));
          const materialLength = parseFloat(selectedOption.getAttribute('data-length'));
          const squareMeters = (materialLength * materialWidth * piecesNeeded) / 10000;
          document.getElementById('material-square-meters').textContent = squareMeters;
        } else {
          console.error("No material option selected.");
        }
      } else {
        console.error("Missing elements: material select, price input, or products-fit field.");
      }
    } catch (error) {
      console.error("Error in reCalculateProducts:", error);
    }
  }

  addProcess(event) {
    event.preventDefault();

    const selectElement = event.target.closest('.nested-fields').querySelector('select[name*="[manufacturing_process_id]"]'); 
    const priceInput = document.getElementById('manufacturing_process_price_display');

    if (selectElement) { 
      const selectedOption = selectElement.selectedOptions[0];

      if (selectedOption) {
        const processId = selectedOption.value;
        const processName = selectedOption.text.split(' - ')[0];
        const processDescription = selectedOption.text.split(' - ')[1];
        const processPrice = parseFloat(priceInput.value);
        const processUnit = selectedOption.dataset.unit;
            
        const materialPieces = parseFloat(document.getElementById('sheets-needed').value) || 0;
        const squareMeters = parseFloat(document.getElementById('material-square-meters').value) || 0;

        let calculatedPrice = 0;
        if (processUnit === "pliego") {
          calculatedPrice = processPrice * materialPieces;
        } else if (processUnit === "mt2" || processUnit === "m2") {
          calculatedPrice = processPrice * squareMeters;
        } else {
          console.error("Unknown process unit:", processUnit);
          return;
        }

        // Get the table body
        const tableBody = this.processesTarget.querySelector('tbody');

        // Create a new row for the process
        const newRow = document.createElement('tr');
        
        newRow.dataset.newProcess = "true";
        newRow.innerHTML = `
          <td>
            <input type="hidden" name="quote[quote_processes_attributes][${this.newProcessId}][manufacturing_process_id]" value="${processId}">
            <span class="process-name">${processName}</span> - 
            <span class="process-description">${processDescription}</span>
          </td>
          <td>
            <a href="#" data-action="click->quotes#removeProcess" class="btn btn-danger">Eliminar</a>
          </td>
          <td name="quote[quote_processes_attributes][${this.newProcessId}][price]" class="process-price-total" data-price-id="${this.newProcessId}"> 
            ${calculatedPrice.toFixed(2)} 
          </td> 
        `;

        // Append the new row to the table body
        tableBody.appendChild(newRow);

        // Update the new process ID counter
        this.newProcessId++;

        this.updateProcessesSubtotal(); 
      }
    }
  }

  updateProcessesSubtotal() {
    let subtotal = 0;
    const processRows = this.processesTarget.querySelectorAll('tbody tr');
    processRows.forEach(row => {
      const priceCell = row.querySelector('td:last-child');
      if (priceCell) {
        const priceValue = parseFloat(priceCell.textContent.replace(/[^0-9.-]+/g, ""));
        subtotal += priceValue;
      }
    });
  
    const subtotalSpan = document.getElementById('processes-subtotal');
    if (subtotalSpan) {
      subtotalSpan.textContent = subtotal.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
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

  updateProcessesSubtotal() {
  let subtotal = 0;
  const priceSpans = this.processesTarget.querySelectorAll('.process-price-total'); 
  priceSpans.forEach(priceSpan => {
    subtotal += parseFloat(priceSpan.textContent); 
  });

  const subtotalSpan = document.getElementById('processes-subtotal');
  if (subtotalSpan) {
    subtotalSpan.textContent = subtotal.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
  }
}

  showProcessDetails(event) {
    const selectedOption = event.target.selectedOptions[0];
    const processPrice = parseFloat(selectedOption.dataset.price);
    const processUnit = selectedOption.dataset.unit;

    const nestedFieldsDiv = event.target.closest('.nested-fields'); 
    const processPriceDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="processPrice"]');
    const processUnitDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="processUnit"]');
  
    if (processPriceDisplay) {
      processPriceDisplay.textContent = `$${processPrice.toFixed(2)}`;
    }
  
    if (processUnitDisplay) {
      processUnitDisplay.textContent = processUnit;
    }
  }

  createProcessField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_process", "g"); 
    const newProcessFields = this.processFieldsTemplate.replace(regexp, newId);
    return newProcessFields;
  }

  showManufactureProcessInfo(event) {
    const selectElement = event.target;
    const processId = parseInt(selectElement.value);

    const selectedOption = selectElement.options[selectElement.selectedIndex];
    const unitDescription = selectedOption.dataset.unit;
    const processPrice = parseFloat(selectedOption.dataset.price);

    const manufacturingProcessUnitDisplay = document.getElementById('manufacturing_process_unit_display');
    if (manufacturingProcessUnitDisplay) {
      manufacturingProcessUnitDisplay.textContent = unitDescription || "";
    }

    const manufacturingProcessPriceDisplay = document.getElementById('manufacturing_process_price_display');
    if (manufacturingProcessPriceDisplay) {
      manufacturingProcessPriceDisplay.value = processPrice ? processPrice.toFixed(2) : "";
    }
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

  addTooling(event) {
    event.preventDefault();
  
    const selectElement = event.target.closest('.nested-fields').querySelector('select[name*="[tooling_id]"]');
    const priceInput = document.getElementById('tooling_price_display');
    const quantityInput = document.getElementById('quantity'); 
  
    if (selectElement && priceInput && quantityInput) {
      const selectedOption = selectElement.selectedOptions[0];
  
      if (selectedOption) {
        const toolingId = selectedOption.value;
        const toolingDescription = selectedOption.text;
        const toolingPrice = parseFloat(priceInput.value);
        const toolingQuantity = parseInt(quantityInput.value, 10); 
  
        const calculatedPrice = toolingPrice * toolingQuantity;
  
        // Get the table body
        const tableBody = this.toolingsTarget.querySelector('tbody'); // Assuming you have a "toolingsTarget"
  
        // Create a new row for the tooling
        const newRow = document.createElement('tr');
        newRow.dataset.newTooling = "true";
        newRow.innerHTML = `
          <td>
            <input type="hidden" name="quote[quote_toolings_attributes][${this.newToolingId}][tooling_id]" value="${toolingId}">
            <span class="tooling-description">${toolingDescription}</span>
            <input type="hidden" name="quote[quote_toolings_attributes][${this.newToolingId}][quantity]" value="${toolingQuantity}">
            <span class="tooling-quantity">(${toolingQuantity})</span>
          </td>
          <td>
            <a href="#" data-action="click->quotes#removeTooling" class="btn btn-danger">Eliminar</a>
          </td>
          <td>
            <span class="tooling-price-total">${calculatedPrice.toFixed(2)}</span>
          </td>
        `;
  
        // Append the new row to the table body
        tableBody.appendChild(newRow);
  
        // Update the new tooling ID counter
        this.newToolingId++;
  
        this.updateToolingsSubtotal();
      } else {
        console.error("No option selected in the tooling select.");
      }
    } else {
      console.error("Select element or price/quantity input for tooling not found!");
    }
  }

  updateToolingsSubtotal() {
    let subtotal = 0;
    const priceSpans = this.toolingsTarget.querySelectorAll('.tooling-price-total'); // Assuming you have a "toolingsTarget"
    priceSpans.forEach(priceSpan => {
      subtotal += parseFloat(priceSpan.textContent);
    });
  
    const subtotalSpan = document.getElementById('toolings-subtotal'); 
    if (subtotalSpan) {
      subtotalSpan.textContent = subtotal.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
    }
  }

  removeTooling(event) {
    event.preventDefault();
  
    const row = event.target.closest('tr');
    if (row) {
      row.remove();
      this.updateToolingsSubtotal();
    }
  }
  
  showToolingDetails(event) {
    const selectedOption = event.target.selectedOptions[0];
    const toolingPrice = parseFloat(selectedOption.dataset.price);
    const toolingUnit = selectedOption.dataset.unit;

    const nestedFieldsDiv = event.target.closest('.nested-fields'); 
    const toolingPriceDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="toolingPrice"]');
    const toolingUnitDisplay = nestedFieldsDiv.querySelector('[data-quotes-target="toolingUnit"]');
  
    if (toolingPriceDisplay) {
      toolingPriceDisplay.textContent = `$${toolingPrice.toFixed(2)}`;
    }
  
    if (toolingUnitDisplay) {
      toolingUnitDisplay.textContent = toolingUnit;
    }
  }

  showToolingInfo(event) {
    const selectElement = event.target; 
    const priceDisplay = selectElement.parentNode.querySelector('input[type="number"]');
    const price = selectElement.options[selectElement.selectedIndex].dataset.price;
    const unit = selectElement.options[selectElement.selectedIndex].dataset.unit;
  
    if (priceDisplay) {
      priceDisplay.value = parseFloat(price).toFixed(2);
    } else {
      console.error("Price display element not found for tooling.");
    }
    
    // The following lines should be inside the if(priceDisplay) block
    const toolingPriceDisplay = document.getElementById('tooling_price_display'); 
    if (toolingPriceDisplay) {
      toolingPriceDisplay.textContent = `$${parseFloat(price).toFixed(2)}`; // Use price here
    }
  
    const toolingUnitDisplay = document.getElementById('tooling_unit_display');
    if (toolingUnitDisplay) {
      toolingUnitDisplay.textContent = unit; 
    }
  }

  createToolingField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_tooling", "g"); 
    const newToolingFields = this.toolingFieldsTemplate.replace(regexp, newId);
    return newToolingFields;
  }

  addToolingToList(toolingDescription, toolingPrice, toolingUnit, calculatedPrice) {
    const newRow = document.createElement('tr'); 
    const descriptionCell = document.createElement('td');
    
    descriptionCell.textContent = toolingDescription;
    newRow.appendChild(descriptionCell);

    const removeCell = document.createElement('td');
    const removeButton = document.createElement('button');
    removeButton.textContent = 'Eliminar';
    removeButton.classList.add('btn', 'btn-danger');
    removeButton.setAttribute('data-action', 'click->quotes#removeTooling');
    removeButton.addEventListener('click', (event) => {
      event.preventDefault(); 
      newRow.remove();
      this.updateToolingsSubtotal();
    });
    removeCell.appendChild(removeButton);
    removeCell.classList.add('text-center');
    newRow.appendChild(removeCell);

    const priceCell = document.createElement('td');
    priceCell.textContent = calculatedPrice.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
    priceCell.style.textAlign = 'right';
    newRow.appendChild(priceCell);

    this.toolingsTarget.querySelector('tbody').appendChild(newRow); 
  }

  showMaterialPrice(event) {
    const selectedOption = event.target.selectedOptions[0];
    const materialPrice = parseFloat(selectedOption.getAttribute('data-price'));
    const materialUnit = selectedOption.getAttribute('data-unit');
    const materialUnitId = selectedOption.getAttribute('data-unit-id');

    const materialPriceDisplay = document.getElementById('material_price');
    if (materialPriceDisplay) {
      materialPriceDisplay.value = materialPrice.toFixed(2);
    }

    const materialUnitDisplay = document.getElementById('material_unit_display');
    if (materialUnitDisplay) {
      materialUnitDisplay.textContent = materialUnit;
    }

    const unitIdField = document.getElementById('quote_material_unit_id');
    if (unitIdField) {
      unitIdField.value = materialUnitId;
    }
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
  
  calculateQuote(event) {
    event.preventDefault();

    // Get the material price from the input value, not the text content
    const materialPriceElement = document.getElementById('material-total-price');
    if (!materialPriceElement) {
      console.error("Material price element not found.");
      return;
    }
    const materialPrice = parseFloat(materialPriceElement.value) || 0;

    // Calculate the sum of process prices
    let processPricesSum = 0;
    if (this.processesTarget) {
      const processRows = this.processesTarget.querySelectorAll('tbody tr');
      processRows.forEach(row => {
        const priceCell = row.querySelector('.process-price-total');
        if (priceCell) {
          const priceValue = parseFloat(priceCell.textContent) || 0;
          processPricesSum += priceValue;
        }
      });
    }

    // Calculate the subtotal
    const subTotalValue = materialPrice + processPricesSum;

    // Update the subtotal field
    const subTotalElement = document.getElementById('quote_subtotal');
    if (subTotalElement) {
      subTotalElement.value = subTotalValue.toFixed(2);
    }

    // Calculate waste
    const wastePercentage = parseFloat(document.getElementById('waste').value) || 0;
    const wasteValue = (subTotalValue * wastePercentage) / 100;
    
    // Update waste value
    const wasteValueElement = document.getElementById('quote_waste_price');
    if (wasteValueElement) {
      wasteValueElement.value = wasteValue.toFixed(2);
    }

    // Calculate margin
    const marginPercentage = parseFloat(document.getElementById('margin').value) || 0;
    const marginValue = (subTotalValue * marginPercentage) / 100;
    
    // Update margin value
    const marginValueElement = document.getElementById('quote_margin_price');
    if (marginValueElement) {
      marginValueElement.value = marginValue.toFixed(2);
    }

    // Calculate total
    const totalValue = subTotalValue + wasteValue + marginValue;
    
    // Update total value
    const totalValueElement = document.getElementById('total-value');
    if (totalValueElement) {
      totalValueElement.value = totalValue.toFixed(2);
    }

    // Calculate and update price per piece
    const productPieces = parseFloat(document.getElementById('quote_product_pieces').value) || 0;
    if (productPieces > 0) {
      const pricePerPiece = totalValue / productPieces;
      const pricePerPieceElement = document.getElementById('price-per-piece');
      if (pricePerPieceElement) {
        pricePerPieceElement.value = pricePerPiece.toFixed(2);
      }
    }
  }

  searchCustomer(event) {
    event.preventDefault();
  
    let organizationField = document.getElementById('quote_customer_organization');
    let selectElement = document.getElementById('quote_customer_organization_select'); 
  
    const searchCustomerPath = '/quotes/search_customer'; 
  
    if (!selectElement) { 
      selectElement = document.createElement('select'); 
      selectElement.id = 'quote_customer_organization_select';
      selectElement.name = 'quote[customer_organization]'; 
      selectElement.classList.add('form-control');
  
      // Instead of replacing, hide the text field and add the select element after it
      organizationField.style.display = 'none'; 
      organizationField.parentNode.insertBefore(selectElement, organizationField.nextSibling); 
  
      // Add an event listener to the dropdown
      selectElement.addEventListener('change', (event) => {
        organizationField.value = event.target.value; // Update the text field value
      });
    } else { 
      selectElement.innerHTML = ''; 
    }
  
    const form = event.target.form;
    const formData = new FormData(form);
  
    fetch(searchCustomerPath, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      return response.json(); 
    })
    .then(data => {
      if (data.organizations && data.organizations.length > 0) {
        const defaultOption = document.createElement('option');
        defaultOption.value = '';
        defaultOption.text = 'Selecciona la organización';
        selectElement.appendChild(defaultOption);
  
        data.organizations.forEach(organization => {
          const option = document.createElement('option');
          option.value = organization; 
          option.text = organization;
          selectElement.appendChild(option);
        });
        
        selectElement.selectedIndex = 1; 
      } else {
        const defaultOption = document.createElement('option');
        defaultOption.value = '';
        defaultOption.text = 'No se encontraron organizaciones'; 
        selectElement.appendChild(defaultOption);
      }
    })
    .catch(error => {
      console.error("Error searching customer:", error); 
      alert("Error searching customer. Please try again."); 
    });
  }

  clearCustomerInfo() {
    const customerInfoDiv = document.getElementById('customer_info'); 
    if (customerInfoDiv) {
      customerInfoDiv.innerHTML = '';
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
  
}