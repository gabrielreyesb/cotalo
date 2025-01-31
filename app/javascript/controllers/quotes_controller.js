import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["processes", "extras", "openIcon", "closeIcon", 
                   "productsPerSheet", "sheetsNeeded", 
                   "materialTotalPrice", "materialSquareMeters",
                   "materialsTable", "materialsSubtotal",
                   "includeExtras", "includeExtrasHidden",
                   "processesSubtotal", "extrasSubtotal"]; 

  connect() {
    this.newProcessId = 0; 
    this.newExtraId = 0;
    this.manualMaterialId = document.getElementById('manual-material-config')?.dataset.manualMaterialId;
    
    // Initialize visualization state
    const showVisualization = document.getElementById('show-visualization');
    if (showVisualization) {
      const container = document.getElementById('visualization-container');
      container.style.display = showVisualization.checked ? 'block' : 'none';
    }
    
    // Add event listeners for product dimension changes and material dimensions
    const productWidthInput = document.getElementById('quote_product_width');
    const productLengthInput = document.getElementById('quote_product_length');
    const materialSelect = document.getElementById('material-select');
    const materialWidthInput = document.getElementById('additional_material_width_display');
    const materialLengthInput = document.getElementById('additional_material_length_display');

    if (productWidthInput && productLengthInput && materialSelect) {
      const updateVisualization = () => {
        const selectedOption = materialSelect.selectedOptions[0];
        if (selectedOption) {
          const materialWidth = parseFloat(materialWidthInput.value) || parseFloat(selectedOption.dataset.width);
          const materialLength = parseFloat(materialLengthInput.value) || parseFloat(selectedOption.dataset.length);
          const productWidth = parseFloat(productWidthInput.value);
          const productLength = parseFloat(productLengthInput.value);
          const marginWidth = parseFloat(document.getElementById('config_margin_width').value) || 0;
          const marginLength = parseFloat(document.getElementById('config_margin_length').value) || 0;
          
          if (materialWidth && materialLength && productWidth && productLength) {
            this.drawMaterialVisualization(
              materialWidth,
              materialLength,
              productWidth + marginWidth,
              productLength + marginLength
            );
          }
        }
      };

      productWidthInput.addEventListener('input', updateVisualization);
      productLengthInput.addEventListener('input', updateVisualization);
      materialSelect.addEventListener('change', updateVisualization);
      materialWidthInput.addEventListener('input', updateVisualization);
      materialLengthInput.addEventListener('input', updateVisualization);
    }
    
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
      const jsonUrl = `/quotes/${quoteId}.json`;
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
      
      fetch(jsonUrl, {
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': csrfToken
        },
        credentials: 'same-origin'
      })
        .then(response => {
          if (response.status === 500) {
            return response.text().then(text => {
              throw new Error(`HTTP error! status: ${response.status}`);
            });
          }
          if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
          }
          return response.json();
        })
        .then(data => {
          // Initialize arrays if they don't exist
          data.quote_materials = data.quote_materials || [];
          data.quote_processes = data.quote_processes || [];
          data.quote_extras = data.quote_extras || [];
          
          this.quote = data;
          this.loadExistingData(data);
        })
        .catch(error => {
          console.error('Error loading quote:', error.message);
        });
    }

    // Add event listener for extras checkbox
    const includeExtrasCheckbox = document.querySelector('input[name="quote[include_extras]"]');
    if (includeExtrasCheckbox) {
      includeExtrasCheckbox.addEventListener('change', (event) => {
        if (this.hasIncludeExtrasHiddenTarget) {
          this.includeExtrasHiddenTarget.value = event.target.checked;
        }
        this.calculateTotals();
      });
    }

    // Add form submission handler
    const form = document.querySelector('form');
    if (form) {
      form.addEventListener('turbo:submit-end', (event) => {
        this.handleFormSubmission(event);
      });

      // Prevent the default form submission
      form.addEventListener('submit', (event) => {
        // Only prevent default if it's not a Turbo submission
        if (!event.target.hasAttribute('data-remote')) {
          event.preventDefault();
        }
      });
    }
  }

  async loadExistingData(data) {
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
    data.quote_materials.forEach((material, index) => {
      const row = document.createElement('tr');
      row.innerHTML = `
          <td class="align-middle text-center">
            <div class="d-flex align-items-center justify-content-center" style="min-width: 80px; margin: 0 auto;">
              <div class="form-check d-flex align-items-center m-0" style="margin-right: 35px !important;">
                <input type="radio" 
                       name="main_material" 
                       class="form-check-input m-0" 
                       data-action="change->quotes#updateMainMaterial"
                       ${material.is_main ? 'checked' : ''}>
              </div>
              <button type="button" 
                      class="btn btn-sm btn-link text-danger p-0 d-flex align-items-center"
                      data-action="click->quotes#removeMaterial">
              <i class="fas fa-trash"></i>
            </button>
            </div>
          </td>
          <td style="text-align: left !important; vertical-align: middle;">${material.is_manual ? material.manual_description : material.material.description}</td>
          <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(material.price_per_unit)}</td>
          <td style="text-align: right !important; vertical-align: middle;">${material.width} cm</td>
          <td style="text-align: right !important; vertical-align: middle;">${material.length} cm</td>
          <td style="text-align: right !important; vertical-align: middle;">
            <input type="number" class="form-control form-control-sm text-end products-per-sheet" value="${material.products_per_sheet}" min="1" data-material-price="${material.price_per_unit}" data-material-width="${material.width}" data-material-length="${material.length}" data-action="change->quotes#updateMaterialCalculations" style="width: 80px; display: inline-block;">
          </td>
          <td style="text-align: right !important; vertical-align: middle;">${material.sheets_needed}</td>
          <td style="text-align: right !important; vertical-align: middle;">${material.square_meters}</td>
          <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(material.total_price)}</td>
          <input type="hidden" name="quote[quote_materials_attributes][${index}][id]" value="${material.id}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][material_id]" value="${material.is_manual ? this.manualMaterialId : material.material_id}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][price_per_unit]" value="${material.price_per_unit}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][width]" value="${material.width}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][length]" value="${material.length}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][products_per_sheet]" value="${material.products_per_sheet}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][sheets_needed]" value="${material.sheets_needed}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][square_meters]" value="${material.square_meters}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][total_price]" value="${material.total_price}">
          <input type="hidden" name="quote[quote_materials_attributes][${index}][is_main]" value="${material.is_main}" class="is-main-input">
          ${material.is_manual ? `
            <input type="hidden" name="quote[quote_materials_attributes][${index}][is_manual]" value="true">
            <input type="hidden" name="quote[quote_materials_attributes][${index}][manual_description]" value="${material.manual_description}">
            <input type="hidden" name="quote[quote_materials_attributes][${index}][manual_unit]" value="${material.manual_unit}">
          ` : ''}
      `;
      materialsTable.querySelector('tbody').appendChild(row);
    });

    // Load processes
    data.quote_processes.forEach(process => {
      const row = document.createElement('tr');
      row.innerHTML = `
          <td class="text-center align-middle">
            <button type="button" 
                    class="btn btn-sm btn-link text-danger"
                    data-action="click->quotes#removeProcess">
              <i class="fas fa-trash"></i>
            </button>
          </td>
          <td class="align-middle" style="text-align: left !important;">${process.manufacturing_process.name} - ${process.manufacturing_process.description}</td>
          <td class="text-right align-middle">$${this.formatPrice(parseFloat(process.unit_price))}</td>
          <td class="text-right align-middle">${process.manufacturing_process.unit.description}</td>
          <td class="text-right align-middle process-price-total">$${this.formatPrice(parseFloat(process.price))}</td>
          <input type="hidden" name="quote[quote_processes_attributes][][id]" value="${process.id}">
          <input type="hidden" name="quote[quote_processes_attributes][][manufacturing_process_id]" value="${process.manufacturing_process_id}">
          <input type="hidden" name="quote[quote_processes_attributes][][price]" value="${parseFloat(process.price).toFixed(2)}">
          <input type="hidden" name="quote[quote_processes_attributes][][unit_price]" value="${parseFloat(process.unit_price).toFixed(2)}">
      `;
      processesTable.querySelector('tbody').appendChild(row);
    });

    // Load extras
    data.quote_extras.forEach(extra => {
      const price = parseFloat(extra.price || extra.extra.price).toFixed(2);
      const quantity = parseInt(extra.quantity, 10);
      const totalPrice = (parseFloat(price) * quantity).toFixed(2);
      
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
        <td style="text-align: right !important">$${this.formatPrice(parseFloat(price))}</td>
        <td style="text-align: right !important">${extra.extra.unit.description}</td>
        <td style="text-align: right !important">${quantity}</td>
        <td style="text-align: right !important" class="extra-price-total">$${this.formatPrice(parseFloat(totalPrice))}</td>
        <input type="hidden" name="quote[quote_extras_attributes][][id]" value="${extra.id}">
        <input type="hidden" name="quote[quote_extras_attributes][][extra_id]" value="${extra.extra_id}">
        <input type="hidden" name="quote[quote_extras_attributes][][quantity]" value="${quantity}">
        <input type="hidden" name="quote[quote_extras_attributes][][price]" value="${price}">
      `;
      extrasTable.querySelector('tbody').appendChild(row);
    });

    this.updateMaterialsSubtotal();
    this.updateProcessesSubtotal();
    this.updateExtrasSubtotal();
  }

  formatPrice(number) {
    return number.toLocaleString('en-US', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
  }

  updateMaterialsSubtotal() {
    let subtotal = 0;
    const priceElements = this.materialsTableTarget.querySelectorAll('td:nth-child(9)');
    priceElements.forEach(el => {
      const row = el.closest('tr');
      if (row && row.style.display !== 'none') {
      const priceText = el.textContent.trim();
      const price = parseFloat(priceText.replace(/[$,]/g, '')) || 0;
      subtotal += price;
      }
    });
    this.materialsSubtotalTarget.textContent = `$${this.formatPrice(subtotal)}`;
    this.calculateTotals();
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
    
    const subtotalElement = this.processesTarget.nextElementSibling.querySelector('span');
    if (subtotalElement) {
      subtotalElement.textContent = `$${this.formatPrice(subtotal)}`;
    }
    this.calculateTotals();
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
    
    if (this.hasExtrasSubtotalTarget) {
      this.extrasSubtotalTarget.textContent = `$${this.formatPrice(subtotal)}`;
    }
    this.calculateTotals();
  }

  addProcess(event) {
    const processSelect = document.getElementById('process-select');
    const selectedOption = processSelect.selectedOptions[0];
    
    if (!selectedOption || selectedOption.value === '') {
      return;
    }

    const processId = selectedOption.value;
    const processName = selectedOption.text;
    const price = parseFloat(document.getElementById('manufacturing_process_price_display').value);
    
    const unit = document.getElementById('manufacturing_process_unit_display').textContent;

    // Calculate total price based on unit type
    let totalPrice = price;
    
    const mainMaterialRow = this.materialsTableTarget.querySelector('input[name="main_material"]:checked')?.closest('tr');
    
    if (mainMaterialRow) {
      if (unit.toLowerCase() === 'mt2') {
        const squareMeters = parseFloat(mainMaterialRow.querySelector('td:nth-child(8)').textContent);
        totalPrice = price * squareMeters;
      } else if (unit.toLowerCase() === 'producto') {
        const materialRequerido = parseFloat(mainMaterialRow.querySelector('td:nth-child(7)').textContent);
        totalPrice = price * materialRequerido;
      }
    }

    const tbody = this.processesTarget.querySelector('tbody');

    const newRow = document.createElement('tr');
    newRow.innerHTML = `
      <td class="text-center align-middle">
        <button type="button" 
                class="btn btn-sm btn-link text-danger"
                data-action="click->quotes#removeProcess">
          <i class="fas fa-trash"></i>
        </button>
      </td>
      <td class="align-middle" style="text-align: left !important;">${processName}</td>
      <td class="text-right align-middle">$${this.formatPrice(price)}</td>
      <td class="text-right align-middle">${unit}</td>
      <td class="text-right align-middle process-price-total">$${this.formatPrice(totalPrice)}</td>
      <input type="hidden" name="quote[quote_processes_attributes][][manufacturing_process_id]" value="${processId}">
      <input type="hidden" name="quote[quote_processes_attributes][][price]" value="${totalPrice.toFixed(2)}">
      <input type="hidden" name="quote[quote_processes_attributes][][unit_price]" value="${price.toFixed(2)}">
    `;

    tbody.appendChild(newRow);

    // Reset the form
    processSelect.value = '';
    document.getElementById('manufacturing_process_price_display').value = '';
    document.getElementById('manufacturing_process_unit_display').textContent = '';

    this.updateProcessesSubtotal();
  }

  removeProcess(event) {
    event.preventDefault();
    const row = event.target.closest('tr'); 
    if (row) {
      // Add _destroy field if it's an existing process
      const processIdInput = row.querySelector('input[name*="quote_processes_attributes"][name*="[id]"]');
      const processIndex = processIdInput?.name.match(/quote\[quote_processes_attributes\]\[(\d+)\]/)?.[1];
      if (processIndex) {
        const destroyField = document.createElement('input');
        destroyField.type = 'hidden';
        destroyField.name = `quote[quote_processes_attributes][${processIndex}][_destroy]`;
        destroyField.value = '1';
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
    
    if (selectedOption) {
      const price = parseFloat(selectedOption.dataset.price);
      
      const unit = selectedOption.dataset.unit;
      
      document.getElementById('manufacturing_process_price_display').value = price.toFixed(2);
      document.getElementById('manufacturing_process_unit_display').textContent = unit;
    }
  }

  addExtra(event) {
    event.preventDefault();

    const selectElement = document.getElementById('extra-select');
    const priceInput = document.getElementById('extra_price_display');
    const quantityInput = document.getElementById('quantity');
    const unitDisplay = document.getElementById('extra_unit_display');

    if (selectElement && priceInput && quantityInput) {
      const selectedOption = selectElement.selectedOptions[0];

      if (selectedOption && selectedOption.value) {
        const extraId = selectedOption.value;
        const extraDescription = selectedOption.text;
        const extraPrice = parseFloat(priceInput.value).toFixed(2);
        const extraQuantity = parseInt(quantityInput.value, 10);
        const unit = unitDisplay.textContent;
        const totalPrice = (parseFloat(extraPrice) * extraQuantity).toFixed(2);

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
          <td class="align-middle" style="text-align: left !important;">${extraDescription}</td>
          <td style="text-align: right !important">$${this.formatPrice(parseFloat(extraPrice))}</td>
          <td style="text-align: right !important">${unit}</td>
          <td class="text-right align-middle">${extraQuantity}</td>
          <td class="text-right align-middle extra-price-total">$${this.formatPrice(parseFloat(totalPrice))}</td>
          <input type="hidden" name="quote[quote_extras_attributes][][extra_id]" value="${extraId}">
          <input type="hidden" name="quote[quote_extras_attributes][][quantity]" value="${extraQuantity}">
          <input type="hidden" name="quote[quote_extras_attributes][][price]" value="${extraPrice}">
        `;

        const tbody = this.extrasTarget.querySelector('tbody');
        tbody.appendChild(newRow);
        
        this.updateExtrasSubtotal();

        // Reset inputs
        selectElement.value = '';
        priceInput.value = '';
        quantityInput.value = '1';
        unitDisplay.textContent = '';
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

  showAdditionalExtraInfo(event) {
    const selectElement = event.target; 
    const selectedOption = selectElement.selectedOptions[0];
    
    if (selectedOption) {
      const rawPrice = selectedOption.dataset.price;
      const price = parseFloat(rawPrice).toFixed(2);
      const unit = selectedOption.dataset.unit;
      
      document.getElementById('extra_price_display').value = price;
      document.getElementById('extra_unit_display').textContent = unit;
    } else {
      document.getElementById('extra_price_display').value = '';
      document.getElementById('extra_unit_display').textContent = '';
    }
  }
  
  calculateTotals(event) {
    // Only prevent default if event exists (i.e., button click)
    if (event) {
    event.preventDefault();
    }

    // Get materials subtotal
    let materialsSubtotal = 0;
    if (this.hasMaterialsSubtotalTarget) {
    const materialsSubtotalText = this.materialsSubtotalTarget.textContent;
      materialsSubtotal = parseFloat(materialsSubtotalText.replace(/[$,]/g, '')) || 0;
    }
    
    // Get processes subtotal
    let processesSubtotal = 0;
    const processesSubtotalElement = this.processesTarget.nextElementSibling.querySelector('span');
    if (processesSubtotalElement && processesSubtotalElement.textContent) {
      processesSubtotal = parseFloat(processesSubtotalElement.textContent.replace(/[$,]/g, '')) || 0;
    }

    // Get extras subtotal
    let extrasSubtotal = 0;
    if (this.hasExtrasSubtotalTarget) {
      const extrasSubtotalElement = this.extrasSubtotalTarget;
      if (extrasSubtotalElement && extrasSubtotalElement.textContent) {
        extrasSubtotal = parseFloat(extrasSubtotalElement.textContent.replace(/[$,]/g, '')) || 0;
      }
    }

    // Only include extras in the total if the checkbox is checked
    const includeExtrasCheckbox = this.includeExtrasTarget;
    const isExtrasChecked = includeExtrasCheckbox && includeExtrasCheckbox.checked;

    if (!isExtrasChecked) {
      if (this.hasIncludeExtrasHiddenTarget) {
      this.includeExtrasHiddenTarget.value = "false";
      }
      extrasSubtotal = 0;
    } else {
      if (this.hasIncludeExtrasHiddenTarget) {
        this.includeExtrasHiddenTarget.value = "true";
      }
    }
    
    // Calculate subtotal
    const subtotal = materialsSubtotal + processesSubtotal + extrasSubtotal;

    // Calculate waste and margin
    const wasteElement = document.getElementById('waste');
    const marginElement = document.getElementById('margin');
    const wastePercentage = wasteElement ? (parseFloat(wasteElement.value) || 0) : 0;
    const marginPercentage = marginElement ? (parseFloat(marginElement.value) || 0) : 0;
    
    const wasteAmount = (subtotal * wastePercentage) / 100;
    const marginAmount = (subtotal * marginPercentage) / 100;
    
    // Calculate final total
    const total = subtotal + wasteAmount + marginAmount;

    // Get product quantity for price per piece
    const quantityElement = document.getElementById('quote_product_quantity');
    const productQuantity = quantityElement ? (parseInt(quantityElement.value) || 0) : 0;
    const pricePerPiece = productQuantity > 0 ? total / productQuantity : 0;

    // Store raw values in hidden fields
    const elements = {
      subtotal: document.getElementById('quote_subtotal'),
      wastePrice: document.getElementById('quote_waste_price'),
      marginPrice: document.getElementById('quote_margin_price'),
      totalQuoteValue: document.getElementById('quote_total_quote_value'),
      productValuePerPiece: document.getElementById('quote_product_value_per_piece'),
      subtotalDisplay: document.getElementById('subtotal-display'),
      wastePriceDisplay: document.getElementById('waste-price-display'),
      marginPriceDisplay: document.getElementById('margin-price-display'),
      totalQuoteValueDisplay: document.getElementById('total-quote-value-display'),
      pricePerPieceDisplay: document.getElementById('price-per-piece-display')
    };

    // Update values only if elements exist
    if (elements.subtotal) elements.subtotal.value = subtotal.toFixed(2);
    if (elements.wastePrice) elements.wastePrice.value = wasteAmount.toFixed(2);
    if (elements.marginPrice) elements.marginPrice.value = marginAmount.toFixed(2);
    if (elements.totalQuoteValue) elements.totalQuoteValue.value = total.toFixed(2);
    if (elements.productValuePerPiece) elements.productValuePerPiece.value = pricePerPiece.toFixed(2);
    
    // Display formatted values with $ and commas in display fields
    if (elements.subtotalDisplay) elements.subtotalDisplay.textContent = `$${this.formatPrice(subtotal)}`;
    if (elements.wastePriceDisplay) elements.wastePriceDisplay.textContent = `$${this.formatPrice(wasteAmount)}`;
    if (elements.marginPriceDisplay) elements.marginPriceDisplay.textContent = `$${this.formatPrice(marginAmount)}`;
    if (elements.totalQuoteValueDisplay) elements.totalQuoteValueDisplay.textContent = `$${this.formatPrice(total)}`;
    if (elements.pricePerPieceDisplay) elements.pricePerPieceDisplay.textContent = `$${this.formatPrice(pricePerPiece)}`;
  }

  searchCustomer(event) {
    event.preventDefault();
    const customerName = document.getElementById('quote_customer_name').value;
    const customerNameField = document.getElementById('quote_customer_name');
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
      if (!response.ok) {
        return response.text().then(text => {
          console.log('Error response text:', text);
          throw new Error(`HTTP error! status: ${response.status}`);
        });
      }
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
            customerNameField.value = selectedResult.name || '';
            // Show the organization field again and remove the select
            organizationField.style.display = '';
            organizationSelect.remove();
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

    const tbody = this.materialsTableTarget.querySelector('tbody');
    const isFirstMaterial = tbody.querySelectorAll('tr').length === 0;

    // Add to table with manual flag and placeholder material ID
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td class="align-middle text-center">
        <div class="d-flex align-items-center justify-content-center" style="min-width: 80px; margin: 0 auto;">
          <div class="form-check d-flex align-items-center m-0" style="margin-right: 35px !important;">
            <input type="radio" 
                   name="main_material" 
                   class="form-check-input m-0" 
                   data-action="change->quotes#updateMainMaterial"
                   ${isFirstMaterial ? 'checked' : ''}>
          </div>
          <button type="button" 
                  class="btn btn-sm btn-link text-danger p-0 d-flex align-items-center"
                  data-action="click->quotes#removeMaterial">
            <i class="fas fa-trash"></i>
          </button>
        </div>
      </td>
      <td style="text-align: left !important; vertical-align: middle;">${description}</td>
      <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(price)}</td>
      <td style="text-align: right !important; vertical-align: middle;">${width} cm</td>
      <td style="text-align: right !important; vertical-align: middle;">${length} cm</td>
      <td style="text-align: right !important; vertical-align: middle;">
        <input type="number" class="form-control form-control-sm text-end products-per-sheet" value="${productsPerSheet}" min="1" data-material-price="${price}" data-material-width="${width}" data-material-length="${length}" data-action="change->quotes#updateMaterialCalculations" style="width: 80px; display: inline-block;">
      </td>
      <td style="text-align: right !important; vertical-align: middle;">${sheetsNeeded}</td>
      <td style="text-align: right !important; vertical-align: middle;">${squareMeters.toFixed(2)}</td>
      <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(totalPrice)}</td>
      <input type="hidden" name="quote[quote_materials_attributes][][material_id]" value="${this.manualMaterialId}">
      <input type="hidden" name="quote[quote_materials_attributes][][is_manual]" value="true">
      <input type="hidden" name="quote[quote_materials_attributes][][manual_description]" value="${description}">
      <input type="hidden" name="quote[quote_materials_attributes][][manual_unit]" value="${unitId}">
      <input type="hidden" name="quote[quote_materials_attributes][][products_per_sheet]" value="${productsPerSheet}">
      <input type="hidden" name="quote[quote_materials_attributes][][sheets_needed]" value="${sheetsNeeded}">
      <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters}">
      <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice}">
      <input type="hidden" name="quote[quote_materials_attributes][][price_per_unit]" value="${price}">
      <input type="hidden" name="quote[quote_materials_attributes][][width]" value="${width}">
      <input type="hidden" name="quote[quote_materials_attributes][][length]" value="${length}">
      <input type="hidden" name="quote[quote_materials_attributes][][is_main]" value="${isFirstMaterial}" class="is-main-input">
    `;
    
    tbody.appendChild(tr);
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

  addMaterial(event) {
    event.preventDefault();
    
    const materialSelect = document.getElementById('material-select');
    const priceInput = document.getElementById('additional_material_price_display');
    const widthInput = document.getElementById('additional_material_width_display');
    const lengthInput = document.getElementById('additional_material_length_display');
    
    if (materialSelect && priceInput && widthInput && lengthInput) {
      const selectedOption = materialSelect.selectedOptions[0];
      
      if (selectedOption) {
        const materialId = selectedOption.value;
        const materialDescription = selectedOption.text;
        const materialPrice = parseFloat(priceInput.value);
        const materialWidth = parseFloat(widthInput.value);
        const materialLength = parseFloat(lengthInput.value);
        
        if (!materialWidth || !materialLength) {
          alert('Por favor ingrese dimensiones válidas para el material');
      return;
    }

        // Get product dimensions and quantity
      const productWidth = parseFloat(document.getElementById('quote_product_width').value);
      const productLength = parseFloat(document.getElementById('quote_product_length').value);
      const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);

        // Get margins from configuration
        const marginWidth = parseFloat(document.getElementById('config_margin_width').value) || 0;
        const marginLength = parseFloat(document.getElementById('config_margin_length').value) || 0;
        
        // Add margins to product dimensions
        const totalProductWidth = productWidth + marginWidth;
        const totalProductLength = productLength + marginLength;
        
        // Calculate how many products fit in each dimension
        const productsInWidth = Math.floor(materialWidth / totalProductWidth);
        const productsInLength = Math.floor(materialLength / totalProductLength);
        
        // Total products that fit in one sheet
        const productsPerSheet = productsInWidth * productsInLength;
        
        // Calculate sheets needed and round up
        const sheetsNeeded = Math.ceil(productQuantity / productsPerSheet);
        
        // Calculate square meters (convert from cm² to m²)
        const squareMeters = (sheetsNeeded * materialWidth * materialLength) / 10000;
        const totalPrice = materialPrice * squareMeters;

        // Draw the visualization
        this.drawMaterialVisualization(materialWidth, materialLength, totalProductWidth, totalProductLength);
        
        const tbody = this.materialsTableTarget.querySelector('tbody');
        const isFirstMaterial = tbody.querySelectorAll('tr').length === 0;
        
        const newRow = document.createElement('tr');
        newRow.innerHTML = `
          <td class="align-middle text-center">
            <div class="d-flex align-items-center justify-content-center" style="min-width: 80px; margin: 0 auto;">
              <div class="form-check d-flex align-items-center m-0" style="margin-right: 35px !important;">
                <input type="radio" 
                       name="main_material" 
                       class="form-check-input m-0" 
                       data-action="change->quotes#updateMainMaterial"
                       ${isFirstMaterial ? 'checked' : ''}>
              </div>
              <button type="button" 
                      class="btn btn-sm btn-link text-danger p-0 d-flex align-items-center"
                      data-action="click->quotes#removeMaterial">
                <i class="fas fa-trash"></i>
              </button>
            </div>
          </td>
          <td style="text-align: left !important; vertical-align: middle;">${materialDescription}</td>
          <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(materialPrice)}</td>
          <td style="text-align: right !important; vertical-align: middle;">${materialWidth} cm</td>
          <td style="text-align: right !important; vertical-align: middle;">${materialLength} cm</td>
          <td style="text-align: right !important; vertical-align: middle;">
            <input type="number" 
                   class="form-control form-control-sm text-end products-per-sheet" 
                   value="${productsPerSheet}" 
                   min="1" 
                   step="0.01"
                   data-material-price="${materialPrice.toFixed(2)}" 
                   data-material-width="${materialWidth}" 
                   data-material-length="${materialLength}" 
                   data-action="change->quotes#updateMaterialCalculations" 
                   style="width: 80px; display: inline-block;">
          </td>
          <td style="text-align: right !important; vertical-align: middle;">${sheetsNeeded}</td>
          <td style="text-align: right !important; vertical-align: middle;">${squareMeters.toFixed(2)}</td>
          <td style="text-align: right !important; vertical-align: middle;">$${this.formatPrice(totalPrice)}</td>
          <input type="hidden" name="quote[quote_materials_attributes][][material_id]" value="${materialId}">
          <input type="hidden" name="quote[quote_materials_attributes][][price_per_unit]" value="${materialPrice.toFixed(2)}">
          <input type="hidden" name="quote[quote_materials_attributes][][width]" value="${materialWidth}">
          <input type="hidden" name="quote[quote_materials_attributes][][length]" value="${materialLength}">
          <input type="hidden" name="quote[quote_materials_attributes][][products_per_sheet]" value="${productsPerSheet}">
          <input type="hidden" name="quote[quote_materials_attributes][][sheets_needed]" value="${sheetsNeeded}">
          <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters.toFixed(2)}">
          <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice.toFixed(2)}">
          <input type="hidden" name="quote[quote_materials_attributes][][is_main]" value="${isFirstMaterial}" class="is-main-input">
        `;
        
        tbody.appendChild(newRow);
        
      this.updateMaterialsSubtotal();
      
        // Reset the form
      materialSelect.value = '';
        priceInput.value = '';
        widthInput.value = '';
        lengthInput.value = '';
        document.getElementById('additional_material_unit_display').textContent = '';
      }
    }
  }

  updateMaterialCalculations(event) {
    const input = event.target;
    const row = input.closest('tr');
    const productQuantity = parseInt(document.getElementById('quote_product_quantity').value);
    
    // Get values from data attributes
    const materialPrice = parseFloat(input.dataset.materialPrice);
    const materialWidth = parseFloat(input.dataset.materialWidth);
    const materialLength = parseFloat(input.dataset.materialLength);
    
    // Get new products per sheet value
    const productsPerSheet = parseInt(input.value);
    
    // Recalculate values
    const sheetsNeeded = Math.ceil(productQuantity / productsPerSheet);
    const squareMeters = (sheetsNeeded * materialWidth * materialLength) / 10000;
    const totalPrice = materialPrice * squareMeters;
    
    // Update displayed values in cells
    row.querySelector('td:nth-child(7)').textContent = sheetsNeeded;  // Material requerido column
    row.querySelector('td:nth-child(8)').textContent = squareMeters.toFixed(2);  // Mts2 column
    row.querySelector('td:nth-child(9)').textContent = `$${this.formatPrice(totalPrice)}`;  // Total column
    
    // Update hidden fields
    const hiddenInputs = row.querySelectorAll('input[type="hidden"]');
    hiddenInputs.forEach(input => {
      const name = input.name;
      if (name.includes('[products_per_sheet]')) {
        input.value = productsPerSheet;
      } else if (name.includes('[sheets_needed]')) {
        input.value = sheetsNeeded;
      } else if (name.includes('[square_meters]')) {
        input.value = squareMeters;
      } else if (name.includes('[total_price]')) {
        input.value = totalPrice;
      }
    });
    
    // Update subtotal and recalculate totals
    this.updateMaterialsSubtotal();
  }

  drawMaterialVisualization(materialWidth, materialLength, productWidth, productLength) {
    const canvas = document.getElementById('material-visualization');
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const padding = 20;
    const textPadding = 15;
    
    // Clear the canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Calculate scale to fit the material in the canvas while leaving room for text
    const scaleX = (canvas.width - 2 * padding) / materialWidth;
    const scaleY = (canvas.height - 2 * padding - 40) / materialLength;
    const scale = Math.min(scaleX, scaleY);
    
    // Draw material outline
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 2;
    ctx.strokeRect(
      padding, 
      padding, 
      materialWidth * scale, 
      materialLength * scale
    );
    
    // Get original product dimensions and margins
    const marginWidth = parseFloat(document.getElementById('config_margin_width').value) || 0;
    const marginLength = parseFloat(document.getElementById('config_margin_length').value) || 0;
    const originalProductWidth = productWidth - marginWidth;
    const originalProductLength = productLength - marginLength;
    
    // Calculate products that fit
    const productsInWidth = Math.floor(materialWidth / productWidth);
    const productsInLength = Math.floor(materialLength / productLength);
    
    // Draw products with margins
    for (let i = 0; i < productsInWidth; i++) {
      for (let j = 0; j < productsInLength; j++) {
        const x = padding + (i * productWidth * scale);
        const y = padding + (j * productLength * scale);
        
        // Draw margin area in light blue with transparency
        ctx.fillStyle = 'rgba(0, 102, 204, 0.1)';
        ctx.fillRect(
          x,
          y,
          productWidth * scale,
          productLength * scale
        );
        
        // Draw actual product area in solid line
        ctx.strokeStyle = '#0066cc';
        ctx.lineWidth = 1;
        ctx.strokeRect(
          x + ((marginWidth/2) * scale),
          y + ((marginLength/2) * scale),
          originalProductWidth * scale,
          originalProductLength * scale
        );
      }
    }
    
    // Add dimensions text with better spacing
    ctx.fillStyle = '#000';
    ctx.font = '12px Arial';
    ctx.fillText(`Producto: ${originalProductWidth}cm × ${originalProductLength}cm (+ margen ${marginWidth}cm × ${marginLength}cm`, padding, canvas.height - (textPadding + 14));
    ctx.fillText(`Material: ${materialWidth}cm × ${materialLength}cm`, padding, canvas.height - textPadding);
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
        <input type="hidden" name="quote[quote_materials_attributes][][square_meters]" value="${squareMeters.toFixed(2)}">
        <input type="hidden" name="quote[quote_materials_attributes][][total_price]" value="${totalPrice.toFixed(2)}">
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
    const widthDisplay = document.getElementById('additional_material_width_display');
    const lengthDisplay = document.getElementById('additional_material_length_display');
    
    if (selectedOption && selectedOption.value) {
      const unit = selectedOption.dataset.unit;
      const price = selectedOption.dataset.price;
      const width = selectedOption.dataset.width;
      const length = selectedOption.dataset.length;
      
      unitDisplay.textContent = unit || '';
      priceDisplay.value = price || '';
      widthDisplay.value = width || '';
      lengthDisplay.value = length || '';
      
      // Store original values as data attributes for reference
      widthDisplay.dataset.originalWidth = width;
      lengthDisplay.dataset.originalLength = length;
    } else {
      unitDisplay.textContent = '';
      priceDisplay.value = '';
      widthDisplay.value = '';
      lengthDisplay.value = '';
      
      widthDisplay.dataset.originalWidth = '';
      lengthDisplay.dataset.originalLength = '';
    }
  }

  updateMainMaterial(event) {
    // Update all is_main hidden inputs to false
    this.materialsTableTarget.querySelectorAll('.is-main-input').forEach(input => {
      input.value = "false";
    });
    
    // Set the selected material's is_main to true
    const selectedRow = event.target.closest('tr');
    if (selectedRow) {
      const mainInput = selectedRow.querySelector('.is-main-input');
      if (mainInput) {
        mainInput.value = "true";
      }
    }
  }

  toggleVisualization(event) {
    const container = document.getElementById('visualization-container');
    if (container) {
      container.style.display = event.target.checked ? 'block' : 'none';
    }
  }

  updateMaterialPrice(event) {
    const input = event.target;
    const row = input.closest('tr');
    const newPrice = parseFloat(input.value);
    
    // Update hidden price field
    const priceField = row.querySelector('input[name*="[price_per_unit]"]');
    if (priceField) {
      priceField.value = newPrice.toFixed(2);  // Ensure 2 decimal places
    }
    
    // Recalculate total price
    const squareMeters = parseFloat(row.querySelector('td:nth-child(8)').textContent);
    const totalPrice = newPrice * squareMeters;
    
    // Update total price display
    const totalPriceCell = row.querySelector('td:nth-child(9)');
    totalPriceCell.textContent = `$${this.formatPrice(totalPrice)}`;
    
    // Update hidden total price field
    const totalPriceField = row.querySelector('input[name*="[total_price]"]');
    if (totalPriceField) {
      totalPriceField.value = totalPrice.toFixed(2);  // Ensure 2 decimal places
    }
    
    this.updateMaterialsSubtotal();
  }

  handleFormSubmission(event) {
    const response = event.detail.fetchResponse;

    if (response.succeeded) {
      // Redirect will be handled by Turbo
      return;
    }

    // If we get here, there was an error
    // The error modal will be rendered by the server through Turbo Stream
    // and automatically shown
  }
}