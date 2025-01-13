import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];

  remove(event) {
    event.preventDefault();
    console.log("Remove event triggered");

    const row = event.target.closest(".property-row");
    if (!row) {
      console.error("No property row found");
      return;
    }

    const keyInput = row.querySelector("input[name*='[key]']");
    if (keyInput) {
      console.log(`Marking property for deletion: ${keyInput.value}`);
      row.classList.add("marked-for-deletion");
      row.querySelectorAll("input").forEach((input) => (input.disabled = true));

      const message = document.createElement("p");
      message.className = "deletion-message text-danger mt-2";
      message.textContent = "This property will be deleted when you save changes.";
      row.appendChild(message);

      const deletedInput = document.createElement("input");
      deletedInput.type = "hidden";
      deletedInput.name = "item[properties_to_remove][]";
      deletedInput.value = keyInput.value;
      this.containerTarget.appendChild(deletedInput);

      const removeButton = row.querySelector("[data-action='properties#remove']");
      removeButton.textContent = "Undo";
      removeButton.dataset.action = "properties#undoRemove";
    }
  }

  undoRemove(event) {
    event.preventDefault();
    console.log("Undo remove event triggered");

    const row = event.target.closest(".property-row");
    if (!row) {
      console.error("No property row found for undo");
      return;
    }

    row.classList.remove("marked-for-deletion");
    row.querySelectorAll("input").forEach((input) => (input.disabled = false));

    const message = row.querySelector(".deletion-message");
    if (message) message.remove();

    const keyInput = row.querySelector("input[name*='[key]']");
    const hiddenInput = this.containerTarget.querySelector(
      `input[name='item[properties_to_remove][]'][value='${keyInput.value}']`
    );
    if (hiddenInput) hiddenInput.remove();

    const undoButton = row.querySelector("[data-action='properties#undoRemove']");
    undoButton.textContent = "Remove";
    undoButton.dataset.action = "properties#remove";
  }
};
