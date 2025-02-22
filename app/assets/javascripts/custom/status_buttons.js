document.addEventListener('turbo:load', function() {
    const statusContainer = document.querySelector('.status-buttons');
    if (!statusContainer) return;
  
    const buttons = statusContainer.querySelectorAll('.status-btn');
    const radios = statusContainer.querySelectorAll('.status-radio');
  
    buttons.forEach(button => {
      button.addEventListener('click', function() {
        // Actualizar radios
        const value = this.dataset.value;
        const radio = document.querySelector(`.status-radio[value="${value}"]`);
        radio.checked = true;
  
        // Actualizar estilos de botones
        buttons.forEach(btn => {
          btn.classList.remove('btn-warning', 'btn-success', 'btn-danger');
          btn.classList.add('btn-light');
        });
  
        // Aplicar estilo al botón seleccionado
        const btnClass = radio.dataset.btnClass;
        this.classList.remove('btn-light');
        this.classList.add(btnClass);
      });
    });
  }); 