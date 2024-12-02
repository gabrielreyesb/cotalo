import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "processes", "toolings", "productsFit", "materialPieces", "materialPrice", "squareMeters"] 

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
  
    const productQuantity = parseFloat(document.getElementById('quote_product_pieces').value);
    const productWidth = parseFloat(document.getElementById('quote_product_width').value);
    const productLength = parseFloat(document.getElementById('quote_product_length').value);

    const configMarginWidth = parseFloat(document.getElementById('config_margin_width').value); 
    const configMarginLength = parseFloat(document.getElementById('config_margin_length').value); 

    const finalProductWidth = productWidth + configMarginWidth
    const finalProductLength = productLength + configMarginLength

    if (isNaN(materialWidth) || isNaN(materialLength) || isNaN(finalProductWidth) || isNaN(finalProductLength)) {
      alert("Dimensiones inválidas. El producto no cabe en el material.");  
  
      const productsFitElement = document.getElementById('products-per-sheet'); 
      if (productsFitElement) {
        productsFitElement.value = 0;
      } else {
        console.error("products-per-sheet element not found!");
      }
      return;
    }

    const productsInWidth = Math.floor(materialWidth / finalProductWidth);
    const productsInLength = Math.floor(materialLength / finalProductLength);
    const totalProducts = productsInWidth * productsInLength;
    document.getElementById('products-per-sheet').value = totalProducts;

    const piecesNeeded = Math.ceil(productQuantity / totalProducts); 
    document.getElementById('sheets-needed').textContent = piecesNeeded;

    const quoteValue = materialPrice * piecesNeeded;
    const formattedQuoteValue = quoteValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
    document.getElementById('material-total-price').textContent = formattedQuoteValue; 

    const squareMeters = (materialLength * materialWidth * piecesNeeded) / 10000;
    document.getElementById('material-square-meters').textContent = squareMeters;
  }

  addProcess(event) {
    event.preventDefault();

    const selectElement = event.target.closest('.nested-fields').querySelector('select[name*="[manufacturing_process_id]"]'); 
    const priceInput = document.getElementById('manufacturing_process_price_display');

    if (selectElement) { 
        const selectedOption = selectElement.selectedOptions[0];

        if (selectedOption) {
            const processDescription = selectedOption.text;
            const processPrice = parseFloat(priceInput.value);
            const processUnit = selectedOption.dataset.unit;
            
            const materialPieces = parseFloat(document.getElementById('sheets-needed').textContent);
            const squareMeters = parseFloat(document.getElementById('material-square-meters').textContent);

            let calculatedPrice = 0;
            if (processUnit === "pliego") {
              calculatedPrice = processPrice * materialPieces;
            } else if (processUnit === "m2") {
              calculatedPrice = processPrice * squareMeters;
            } else {
              console.error("Unknown process unit:", processUnit, calculatedPrice);
            }

            this.addProcessToList(processDescription, processPrice, processUnit, calculatedPrice);
            this.updateProcessesSubtotal();
        } else {
            console.error("No option selected in the manufacturing process select.");
        }
    } else {
        console.error("Select element for manufacturing process not found!");
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

  addTooling(event) {
    event.preventDefault();

    const selectElement = event.target.closest('.nested-fields').querySelector('select[name*="[tooling_id]"]'); 
    const quantityInput = event.target.closest('.nested-fields').querySelector('input[name*="[quantity]"]'); 
    const priceInput = event.target.closest('.nested-fields').querySelector('input[type="number"]');

    if (selectElement) {
      const selectedOption = selectElement.selectedOptions[0];

      if (selectedOption && quantityInput) {
        const toolingDescription = selectedOption.text;
        const toolingPrice = parseFloat(priceInput.value);
        const toolingUnit = selectedOption.dataset.unit;
        const toolingQuantity = parseInt(quantityInput.value);

        let calculatedPrice = 0;
        if (toolingUnit === "pieza") {
          calculatedPrice = toolingPrice * toolingQuantity;;
        } else {
          console.error("Unknown tooling unit:", toolingUnit, calculatedPrice);
        }

        this.addToolingToList(toolingDescription, toolingPrice, toolingUnit, calculatedPrice);
        this.updateToolingsSubtotal();
      } else {
          console.error("No option selected in the tooling select.");
      } 
    } else {
      console.error("Select element for tooling not found!");
    }
  }

  updateToolingsSubtotal() {
    let subtotal = 0;
    const toolingRows = this.toolingsTarget.querySelectorAll('tbody tr');
    toolingRows.forEach(row => {
      const priceCell = row.querySelector('td:last-child');
      if (priceCell) {
        const priceValue = parseFloat(priceCell.textContent.replace(/[^0-9.-]+/g, ""));
        subtotal += priceValue;
      }
    });
  
    const subtotalSpan = document.getElementById('toolings-subtotal');
    if (subtotalSpan) {
      subtotalSpan.textContent = subtotal.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
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

  removeTooling(event) {
    event.preventDefault();
    const row = event.target.closest('tr'); 
    if (row) {
      row.remove();
      this.updateToolingsSubtotal();
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
  
  reCalculateProducts(event) {
    event.preventDefault();
  
    const materialSelect = document.getElementById('quote_material_id');
    const priceInput = document.getElementById('material_price_display');
    const productsFitField = document.getElementById('products-fit'); 
    const productQuantity = parseFloat(document.getElementById('quote_pieces').value);
  
    if (materialSelect && priceInput && productsFitField) {
      const selectedOption = materialSelect.selectedOptions[0];
      const materialWidth = parseFloat(selectedOption.getAttribute('data-width'));
      const materialLength = parseFloat(selectedOption.getAttribute('data-length'));
      const materialPrice = parseFloat(priceInput.value);
      const totalProducts = parseFloat(productsFitField.value); // Get value from input field
  
      if (isNaN(materialWidth) || isNaN(materialLength) || isNaN(totalProducts)) {
        console.error("Invalid dimensions. Please check the input values and data attributes.");
        return;
      }
  
      const piecesNeeded = Math.ceil(productQuantity / totalProducts); 
      document.getElementById('material-pieces').textContent = piecesNeeded;
  
      const quoteValue = materialPrice * piecesNeeded;
      const formattedQuoteValue = quoteValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
      document.getElementById('material-price').textContent = formattedQuoteValue; 
  
      const squareMeters = (materialLength * materialWidth * piecesNeeded) / 10000;
      document.getElementById('square-meters').textContent = squareMeters;
    } else {
      console.error("Missing elements: material select, price input, or products-fit field.");
    }
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

  showManufactureProcessInfo(event) {
    const selectedOption = event.target.selectedOptions[0];
    const manufacturingProcessPrice = parseFloat(selectedOption.getAttribute('data-price'));
    const manufacturingProcessUnit = selectedOption.getAttribute('data-unit');
  
    const manufacturingProcessPriceDisplay = document.getElementById('manufacturing_process_price_display');
    if (manufacturingProcessPriceDisplay) {
      manufacturingProcessPriceDisplay.value = manufacturingProcessPrice.toFixed(2);
    }
  
    const manufacturingProcessUnitDisplay = document.getElementById('manufacturing_process_unit_display');
    if (manufacturingProcessUnitDisplay) {  
      manufacturingProcessUnitDisplay.textContent = manufacturingProcessUnit;
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

  createProcessField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_process", "g"); 
    const newProcessFields = this.processFieldsTemplate.replace(regexp, newId);
    return newProcessFields;
  }

  createToolingField() {
    const newId = new Date().getTime(); 
    const regexp = new RegExp("new_quote_tooling", "g"); 
    const newToolingFields = this.toolingFieldsTemplate.replace(regexp, newId);
    return newToolingFields;
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

    // Get the material price
    const materialPriceElement = document.getElementById('material-total-price');
    
    const productQuantity = parseFloat(document.getElementById('sheets-needed').value);

    if (!materialPriceElement) {
      console.error("Material price element not found.");
      return;
    }
    const materialPrice = parseFloat(materialPriceElement.textContent.replace(/[^0-9.-]+/g, ""));

    // Calculate the sum of process prices
    let processPricesSum = 0;
    if (this.processesTarget) {
      const processRows = this.processesTarget.querySelectorAll('tbody tr');
      processRows.forEach(row => {
        const priceCell = row.querySelector('td:last-child');
        if (priceCell) {
          const priceValue = parseFloat(priceCell.textContent.replace(/[^0-9.-]+/g, ""));
          processPricesSum += priceValue;
        } else {
          console.error("Price cell not found in process row.");
        }
      });
    } else {
      console.warn("Processes target not found. Assuming no processes added.");
    }

    // Calculate the subtotal
    const subTotalValue = materialPrice + processPricesSum;
  
    // Update the subtotal field in the form
    const subTotalValueElement = document.getElementById('quote_subtotal');
    if (!subTotalValueElement) {
      console.error("Subtotal value element not found.");
      return;
    }
    subTotalValueElement.value = subTotalValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
  
    // Calculate the waste value
    const wastePercentageElement = document.getElementById('waste');
    if (!wastePercentageElement) {
      console.error("Waste percentage element not found.");
      return;
    }
    const wastePercentage = parseFloat(wastePercentageElement.value);
    const wasteValue = (subTotalValue * wastePercentage) / 100;

    // Update the waste value field in the form
    const wasteValueElement = document.getElementById('quote_waste_price'); 
    console.error("Segundo check");
    if (!wasteValueElement) {
      return;
    }
    wasteValueElement.value = wasteValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 

    // Calculate the margin value
    const marginPercentageElement = document.getElementById('margin');
    if (!marginPercentageElement) {
      console.error("Margin percentage element not found.");
      return;
    }
    const marginPercentage = parseFloat(marginPercentageElement.value);
    const marginValue = (subTotalValue * marginPercentage) / 100;
  
    // Update the margin value field in the form
    const marginValueElement = document.getElementById('quote_margin_price'); 
    if (!marginValueElement) {
      console.error("Margin value element not found.");
      return;
    }
    marginValueElement.value = marginValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
    // Calculate the total value
    const totalValue = subTotalValue + wasteValue + marginValue;

    // Update the total value field in the form  
    const totalValueElement = document.getElementById('total-value'); 
    if (!totalValueElement) {
      console.error("Total value element not found.");
      return;
    }
    totalValueElement.value = totalValue.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 

    // Update the value per piece field in the form  
    const valuePerPieceElement = document.getElementById('price-per-piece'); 
    if (!valuePerPieceElement) {
      console.error("Value per piece element not found.");
      return;
    }

    const valuePerPiece = totalValue / productQuantity; 
    valuePerPieceElement.value = valuePerPiece.toLocaleString('en-US', { style: 'currency', currency: 'USD' }); 
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
      organizationField.replaceWith(selectElement); 
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
}