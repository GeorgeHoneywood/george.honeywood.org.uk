/*
 * Handles mobile nav
 */

function toggleMobileNavState() {
  const body = document.querySelector("body");
  body.classList.toggle("nav--active");
}

/*
 * Initializes burger functionality
 */

function initBurger() {
  const burger = document.querySelector(".burger");
  burger.addEventListener("click", toggleMobileNavState);
}

initBurger();

let currentTheme = window.matchMedia("(prefers-color-scheme: dark)").matches;

// so we can tell what theme we are currently on
let storedTheme = localStorage.getItem("theme");
if (storedTheme === "dark") {
  currentTheme = true;
} else if (storedTheme === "default") {
  currentTheme = false;
}

const themeSwitcher = document.getElementById("theme-switcher");
themeSwitcher.addEventListener("click", () => {
  currentTheme = !currentTheme;
  setColorScheme(currentTheme);

  localStorage.setItem("theme", currentTheme ? "dark" : "default");
});
