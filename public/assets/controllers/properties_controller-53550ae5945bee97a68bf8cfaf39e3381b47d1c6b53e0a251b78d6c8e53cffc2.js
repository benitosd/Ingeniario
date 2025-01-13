import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];

  add(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML;
    this.containerTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest(".property-row");
    const keyInput = row.querySelector("input[name*='[key]']");

    // Si existe un input con la clave, marcar como pendiente de eliminación
    if (keyInput) {
      row.classList.add("marked-for-deletion");
      row.querySelectorAll("input").forEach(input => input.disabled = true);

      const message = document.createElement("p");
      message.className = "deletion-message text-danger mt-2";
      message.textContent = "This property will be deleted when you save changes.";
      row.appendChild(message);

      // Agregar un campo oculto para procesar la eliminación en el servidor
      const deletedInput = document.createElement("input");
      deletedInput.type = "hidden";
      deletedInput.name = "item[properties_to_remove][]";
      deletedInput.value = keyInput.value;
      this.containerTarget.appendChild(deletedInput);

      // Cambiar el texto del botón a "Undo"
      const removeButton = row.querySelector("[data-action='properties#remove']");
      removeButton.textContent = "Undo";
      removeButton.dataset.action = "properties#undoRemove";
    }
  }

  undoRemove(event) {
    event.preventDefault();
    const row = event.target.closest(".property-row");

    // Restaurar los campos y eliminar el mensaje de eliminación
    row.classList.remove("marked-for-deletion");
    row.querySelectorAll("input").forEach(input => input.disabled = false);

    const message = row.querySelector(".deletion-message");
    if (message) message.remove();

    // Eliminar el campo oculto de eliminación
    const keyInput = row.querySelector("input[name*='[key]']");
    const hiddenInput = this.containerTarget.querySelector(`input[name='item[properties_to_remove][]'][value='${keyInput.value}']`);
    if (hiddenInput) hiddenInput.remove();

    // Cambiar el texto del botón de nuevo a "Remove"
    const undoButton = row.querySelector("[data-action='properties#undoRemove']");
    undoButton.textContent = "Remove";
    undoButton.dataset.action = "properties#remove";
  }
};
