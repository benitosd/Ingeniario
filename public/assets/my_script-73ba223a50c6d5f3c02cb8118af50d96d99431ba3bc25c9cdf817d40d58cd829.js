// Test if jquery is loaded by typing $.fn.jquery in the console as per
// https://stackoverflow.com/questions/6973941/how-to-check-what-version-of-jquery-is-loaded/26674265#26674265

// This function runs on every page "load"
document.addEventListener("turbo:load", () => {
    document.documentElement.style.setProperty("--fixed-cards-padding", "15.5rem");
    
    const updateCardsPosition = () => {
      const root = document.documentElement;
      const sidebarToggled = document.body.classList.contains("sb-sidenav-toggled");
    
      if (sidebarToggled) {
        root.style.setProperty("--fixed-cards-padding", "15.5rem");
      } else {
        root.style.setProperty("--fixed-cards-padding", "1.5rem");
      }
    };
  
    // Inicializa al cargar la página
    
    const sidebarToggle = document.body.querySelector("#sidebarToggle");
  
    // Mantener el estado del sidebar entre sesiones
    if (localStorage.getItem("sb|sidebar-toggle") === "true") {
      document.body.classList.add("sb-sidenav-toggled");
      document.documentElement.style.setProperty("--fixed-cards-padding", "1.5rem");
    }
  
    // Configurar evento para alternar la barra lateral
    if (sidebarToggle) {
      sidebarToggle.addEventListener("click", (event) => {
        event.preventDefault();
        updateCardsPosition();
        document.body.classList.toggle("sb-sidenav-toggled");
        localStorage.setItem("sb|sidebar-toggle", document.body.classList.contains("sb-sidenav-toggled"));
      });
    }
  });
  
		
