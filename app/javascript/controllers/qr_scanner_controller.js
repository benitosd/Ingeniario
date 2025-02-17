import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["result", "stocksContainer"]
  static values = {
    isScanning: Boolean,
    isTransitioning: Boolean
  }

  connect() {
    if (typeof Html5Qrcode === 'undefined') {
      setTimeout(() => this.connect(), 100);
      return;
    }

    this.lastSuccessfulScan = null;
    this.scanCooldown = 2000; // 2 segundos entre escaneos
    this.isProcessing = false;

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
    if (!document.getElementById("reader")) {
      console.error("Elemento 'reader' no encontrado");
      return;
    }

    this.html5Qrcode = new Html5Qrcode("reader");
    this.isTransitioningValue = false;
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

    const readerElement = this.element.querySelector('#reader');
    if (readerElement) {
      readerElement.before(container);
    }

    // Agregar event listener para el input de archivo
    fileInput.addEventListener('change', (e) => this.handleFileSelect(e));
  }

  handleFileSelect(event) {
    const file = event.target.files[0];
    if (!file) return;

    if (!this.html5Qrcode) {
      this.showAlert("Escáner no inicializado", "error");
      return;
    }

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
    if (!this.html5Qrcode) {
      this.showAlert("Escáner no inicializado", "error");
      return Promise.reject(new Error("Escáner no inicializado"));
    }

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
    if (this.html5Qrcode?.isScanning) {
      return this.html5Qrcode.stop();
    }
    return Promise.resolve();
  }

  onScanSuccess(decodedText) {
    const now = Date.now();
    
    if (this.lastSuccessfulScan && (now - this.lastSuccessfulScan) < this.scanCooldown) {
      console.log("Ignorando escaneo - muy pronto después del último");
      return;
    }

    // Pausar el escáner temporalmente
    this.html5Qrcode.pause();
    
    console.log("Texto decodificado del QR:", decodedText);
    
    if (this.isStockAlreadyAdded(decodedText)) {
      this.showAlert("Este stock ya ha sido agregado", "warning");
      setTimeout(() => this.html5Qrcode.resume(), 1000);
      return;
    }
    
    this.lastSuccessfulScan = now;
    this.addStockToReport(decodedText).finally(() => {
      setTimeout(() => this.html5Qrcode.resume(), 1000);
    });
  }

  onScanError(error) {
    if (!error.includes("No MultiFormat Readers")) {
      console.warn(`Error del escáner: ${error}`);
    }
  }

  isStockAlreadyAdded(reference) {
    // Limpiar la referencia de espacios en blanco
    const cleanReference = reference.trim();
    
    // Buscar en las referencias existentes
    const existingReferences = Array.from(
      this.stocksContainerTarget.querySelectorAll('.stock-reference')
    ).map(element => element.textContent.trim());
    
    // Verificar si ya existe
    return existingReferences.includes(cleanReference);
  }

  async addStockToReport(reference) {
    // Si ya está procesando un stock, ignorar
    if (this.isProcessing) {
      console.log("Ya está procesando un stock, ignorando nueva lectura");
      return;
    }

    try {
      this.isProcessing = true;
      this.showAlert("Buscando stock...", "info");
      
      const response = await fetch(`/stocks/find_by_reference?reference=${encodeURIComponent(reference)}`);
      if (!response.ok) throw new Error(`Error HTTP! estado: ${response.status}`);
      
      const stock = await response.json();
      if (!stock) throw new Error('Stock no encontrado');

      // Imprimir la respuesta completa para debug
      console.log('Respuesta del servidor:', stock);

      // Validar datos del stock
      this.validarDatosStock(stock);
      
      // Verificar nuevamente si el stock ya fue agregado (por si acaso)
      if (this.isStockAlreadyAdded(reference)) {
        this.showAlert("Este stock ya ha sido agregado", "warning");
        return;
      }

      if (stock.available) {
        await this.appendStockRow(stock);
        this.showAlert("Stock agregado correctamente", "success");
      } else {
        this.showAlert("Este stock no está disponible", "warning");
      }
    } catch (error) {
      console.error('Error:', error);
      this.showAlert(`Error: ${error.message}`, "danger");
    } finally {
      this.isProcessing = false;
    }
  }

  validarDatosStock(stock) {
    // Verificar que stock sea un objeto
    if (!stock || typeof stock !== 'object') {
      throw new Error('Datos de stock inválidos');
    }
    
    // Imprimir el stock para debug
    console.log('Datos de stock recibidos:', stock);
    
    return true;
  }

  appendStockRow(stock) {
    try {
      // Usar el botón de añadir del nested-form para crear una nueva fila
      const addButton = document.querySelector('[data-action="nested-form#add"]');
      if (!addButton) {
        throw new Error('No se encontró el botón para agregar nueva fila');
      }
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
      throw error; // Re-lanzar el error para manejarlo en addStockToReport
    }
  }

  showAlert(mensaje, tipo = 'info', {
    duracion = 3000,
    descartable = true
  } = {}) {
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${tipo} ${descartable ? 'alert-dismissible' : ''} fade show`;
    alertDiv.innerHTML = `
      ${mensaje}
      ${descartable ? `<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>` : ''}
    `;
    
    // Limpiar alertas existentes del mismo tipo
    this.resultTarget.querySelectorAll(`.alert-${tipo}`).forEach(alert => alert.remove());
    
    this.resultTarget.appendChild(alertDiv);

    if (duracion) {
      setTimeout(() => alertDiv.remove(), duracion);
    }
  }

  toggleScanner() {
    if (this.isTransitioningValue) {
      console.log("Scanner en transición, espere por favor");
      return;
    }

    this.isTransitioningValue = true;

    try {
      if (this.html5Qrcode?.isScanning) {
        this.html5Qrcode.stop()
          .then(() => {
            this.showAlert("Scanner detenido", "info");
            this.isTransitioningValue = false;
          })
          .catch(err => {
            console.error("Error al detener el scanner:", err);
            this.showAlert("Error al detener el scanner", "danger");
            this.isTransitioningValue = false;
          });
      } else {
        this.startCamera()
          .then(() => {
            this.showAlert("Scanner iniciado", "info");
            this.isTransitioningValue = false;
          })
          .catch(err => {
            console.error("Error al iniciar el scanner:", err);
            this.showAlert("Error al iniciar el scanner", "danger");
            this.isTransitioningValue = false;
          });
      }
    } catch (error) {
      console.error("Error en toggleScanner:", error);
      this.isTransitioningValue = false;
    }
  }

  disconnect() {
    if (this.html5Qrcode?.isScanning) {
      this.stopCamera()
        .catch(console.error)
        .finally(() => {
          this.html5Qrcode = null;
          this.isTransitioningValue = false;
        });
    }
  }
}