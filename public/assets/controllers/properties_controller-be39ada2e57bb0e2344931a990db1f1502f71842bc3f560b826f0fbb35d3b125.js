import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];

  add(event) {
    event.preventDefault();
    const uniqueKey = Date.now(); // También puedes usar SecureRandom.uuid si necesitas mayor aleatoriedad
    const content = this.templateTarget.innerHTML.replace(/new_key/g, uniqueKey);
    this.containerTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest(".property-row");
    if (!row) return;

    // Marcar la fila como pendiente de eliminación
    row.classList.add("marked-for-deletion");
    row.querySelectorAll("input").forEach((input) => (input.disabled = true));

    // Mostrar mensaje visual
    let message = row.querySelector(".deletion-message");
    if (!message) {
      message = document.createElement("p");
      message.className = "deletion-message text-danger mt-2";
      message.textContent = "This property will be deleted when you save changes.";
      row.appendChild(message);
    }

    // Cambiar el botón a "Undo"
    const button = row.querySelector("[data-action='properties#remove']");
    button.textContent = "Undo";
    button.dataset.action = "properties#undoRemove";

    // Añadir un campo oculto para enviar la eliminación al servidor
    const keyInput = row.querySelector("input[name*='[key]']");
    if (keyInput) {
      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = "item[properties_to_remove][]";
      hiddenInput.value = keyInput.value;
      this.containerTarget.appendChild(hiddenInput);
    }
  }

  undoRemove(event) {
    event.preventDefault();
    const row = event.target.closest(".property-row");
    if (!row) return;

    // Restaurar la fila
    row.classList.remove("marked-for-deletion");
    row.querySelectorAll("input").forEach((input) => (input.disabled = false));

    // Eliminar mensaje visual
    const message = row.querySelector(".deletion-message");
    if (message) message.remove();

    // Cambiar el botón de nuevo a "Remove"
    const button = row.querySelector("[data-action='properties#undoRemove']");
    button.textContent = "Remove";
    button.dataset.action = "properties#remove";

    // Eliminar el campo oculto asociado
    const keyInput = row.querySelector("input[name*='[key]']");
    if (keyInput) {
      const hiddenInput = this.containerTarget.querySelector(
        `input[name='item[properties_to_remove][]'][value='${keyInput.value}']`
      );
      if (hiddenInput) hiddenInput.remove();
    }
  }
};
