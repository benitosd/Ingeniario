// app/javascript/controllers/qr_scanner_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result", "stocksContainer"]

  connect() {
    if (typeof Html5Qrcode === 'undefined') {
      setTimeout(() => this.connect(), 100);
      return;
    }

    // Limpiar cualquier instancia previa
    if (this.html5Qrcode) {
      if (this.html5Qrcode.isScanning) {
        this.html5Qrcode.stop()
          .then(() => {
            this.html5Qrcode = null;
            this.initializeScanner();
          });
      } else {
        this.html5Qrcode = null;
        this.initializeScanner();
      }
    } else {
      this.initializeScanner();
    }
  }

  initializeScanner() {
    this.html5Qrcode = new Html5Qrcode("reader");
    this.isTransitioning = false;
    this.createInterface();
  }

  createInterface() {
    const container = document.createElement('div');
    container.className = 'qr-controls';

    // Input para archivos
    const fileInput = document.createElement('input');
    fileInput.type = 'file';
    fileInput.accept = 'image/*';
    fileInput.className = 'form-control mb-3';
    fileInput.id = 'qr-input-file';
    
    // Label para el input
    const fileLabel = document.createElement('label');
    fileLabel.htmlFor = 'qr-input-file';
    fileLabel.className = 'form-label';
    fileLabel.textContent = 'Seleccionar imagen con código QR';

    // Agregar todo al DOM
    container.appendChild(fileLabel);
    container.appendChild(fileInput);

    this.element.querySelector('#reader').before(container);

    // Agregar event listener para el input de archivo
    fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    if (!file) return;

    this.showAlert("Procesando imagen...", "info");

    this.html5Qrcode.scanFile(file)
      .then(decodedText => {
        console.log("Resultado:", decodedText);
        this.onScanSuccess(decodedText);
      })
      .catch(err => {
        console.error("Error al escanear:", err);
        this.showAlert("No se pudo leer el código QR", "danger");
      });
  }

  startCamera() {
    return this.html5Qrcode.start(
      { facingMode: "environment" },
      {
        fps: 10,
        qrbox: { width: 250, height: 250 }
      },
      this.onScanSuccess.bind(this),
      this.onScanError.bind(this)
    );
  }

  stopCamera() {
    if (this.html5Qrcode.isScanning) {
      return this.html5Qrcode.stop();
    }
    return Promise.resolve();
  }
  onScanSuccess(decodedText) {
    console.log("Texto decodificado del QR:", decodedText);
    
    if (this.isStockAlreadyAdded(decodedText)) {
      this.showAlert("Este stock ya ha sido agregado", "warning");
      return;
    }
    
    this.addStockToReport(decodedText);
  }

  onScanError(error) {
    if (!error.includes("No MultiFormat Readers")) {
      console.warn(`Error del escáner: ${error}`);
    }
  }

  isStockAlreadyAdded(reference) {
    return Array.from(this.stocksContainerTarget.querySelectorAll('.stock-reference'))
      .some(element => element.textContent === reference);
  }

  addStockToReport(reference) {
    this.showAlert("Buscando stock...", "info");
    
    fetch(`/stocks/find_by_reference?reference=${reference}`)
      .then(response => {
        if (!response.ok) throw new Error('Network response was not ok');
        return response.json();
      })
      .then(stock => {
        if (stock.available) {
          this.appendStockRow(stock);
          this.showAlert("Stock agregado correctamente", "success");
        } else {
          this.showAlert("Este stock no está disponible", "warning");
        }
      })
      .catch(error => {
        console.error('Error:', error);
        this.showAlert("Error al buscar el stock", "danger");
      });
  }

  appendStockRow(stock) {
    try {
      // Usar el botón de añadir del nested-form para crear una nueva fila
      const addButton = document.querySelector('[data-action="nested-form#add"]');
      addButton.click();
  
      // Obtener la última fila añadida
      const lastRow = this.stocksContainerTarget.lastElementChild;
      if (!lastRow) {
        throw new Error('No se pudo encontrar la fila agregada');
      }
  
      // Actualizar los campos en la nueva fila
      const referenceField = lastRow.querySelector('.stock-reference');
      const nameField = lastRow.querySelector('.stock-name');
      const stockIdField = lastRow.querySelector('.stock-id-field');
      const returnDateInput = lastRow.querySelector('input[name*="[return_date]"]');
  
      if (referenceField) referenceField.textContent = stock.reference;
      if (nameField) nameField.textContent = stock.item_name;
      if (stockIdField) stockIdField.value = stock.id;
      if (returnDateInput) returnDateInput.value = new Date().toISOString().split('T')[0];
  
    } catch (error) {
      console.error('Error al agregar fila:', error);
      this.showAlert("Error al agregar el stock a la tabla", "danger");
    }
  }
  showAlert(message, type = 'info', removeAfter = true) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show`;
    alertDiv.innerHTML = `
      ${message}
      <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;
    
    const existingAlerts = this.resultTarget.querySelectorAll(`.alert-${type}`);
    existingAlerts.forEach(alert => alert.remove());
    
    this.resultTarget.appendChild(alertDiv);

    if (removeAfter) {
      setTimeout(() => alertDiv.remove(), 3000);
    }
  }

  toggleCamera() {
    if (this.html5Qrcode.isScanning) {
      this.stopCamera();
    } else {
      this.startCamera();
    }
  }

  toggleScanner() {
    // Si ya está en transición, ignoramos el click
    if (this.isTransitioning) {
      console.log("Scanner en transición, espere por favor");
      return;
    }

    this.isTransitioning = true;

    try {
      if (this.html5Qrcode.isScanning) {
        this.html5Qrcode.stop()
          .then(() => {
            this.showAlert("Scanner detenido", "info");
            this.isTransitioning = false;
          })
          .catch(err => {
            console.error("Error al detener el scanner:", err);
            this.showAlert("Error al detener el scanner", "danger");
            this.isTransitioning = false;
          });
      } else {
        this.startCamera()
          .then(() => {
            this.showAlert("Scanner iniciado", "info");
            this.isTransitioning = false;
          })
          .catch(err => {
            console.error("Error al iniciar el scanner:", err);
            this.showAlert("Error al iniciar el scanner", "danger");
            this.isTransitioning = false;
          });
      }
    } catch (error) {
      console.error("Error en toggleScanner:", error);
      this.isTransitioning = false;
    }
  }

  disconnect() {
    if (this.html5Qrcode) {
      if (this.html5Qrcode.isScanning) {
        this.html5Qrcode.stop()
          .then(() => {
            this.html5Qrcode = null;
            this.isTransitioning = false;
          })
          .catch(err => {
            console.error("Error al limpiar el scanner:", err);
            this.html5Qrcode = null;
            this.isTransitioning = false;
          });
      } else {
        this.html5Qrcode = null;
        this.isTransitioning = false;
      }
    }
  }
}