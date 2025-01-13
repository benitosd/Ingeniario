import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template", "help"]; // Define targets para el contenedor y la plantilla

  add(event) {
    event.preventDefault();
    const content = this.templateTarget.innerHTML;
    this.containerTarget.insertAdjacentHTML("beforeend", content);
  }

  remove(event) {
    event.preventDefault();
    const row = event.target.closest(".property-row");
    row.remove();
  }

  reset(event) {
    event.preventDefault();
    this.containerTarget.innerHTML = ""; // Limpia todas las propiedades dinámicas
  }

  validate(event) {
    const rows = this.containerTarget.querySelectorAll(".property-row");
    let isValid = true;

    rows.forEach((row) => {
      const keyInput = row.querySelector("input[name*='[key]']");
      const valueInput = row.querySelector("input[name*='[value]']");
      const keyError = row.querySelector(".key-error");
      const valueError = row.querySelector(".value-error");

      keyInput.classList.remove("is-invalid");
      valueInput.classList.remove("is-invalid");
      if (keyError) keyError.textContent = "";
      if (valueError) valueError.textContent = "";

      if (!keyInput.value.trim()) {
        keyInput.classList.add("is-invalid");
        keyError.textContent = "Key cannot be blank.";
        isValid = false;
      }

      if (!valueInput.value.trim()) {
        valueInput.classList.add("is-invalid");
        valueError.textContent = "Value cannot be blank.";
        isValid = false;
      }
    });

    if (!isValid) {
      event.preventDefault();
    }
  }
};
