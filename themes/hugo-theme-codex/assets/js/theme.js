/**
 * set color scheme
 * @param {boolean} dark - true for dark, false for light
 */
function setColorScheme(dark) {
  let root = document.querySelector("html");
  let meta = document.querySelector('meta[name="theme-color"]');

  if (!meta) {
    newNode = document.createElement("meta");
    newNode.name = "theme-color";
    meta = document.head.appendChild(newNode);
  }

  if (dark === true) {
    root.classList.remove("theme--default");
    root.classList.add("theme--dark");
    meta.setAttribute("content", "#181a1b");
  } else {
    root.classList.remove("theme--dark");
    root.classList.add("theme--default");
    meta.setAttribute("content", "#ffffff");
  }
}

window
  .matchMedia("(prefers-color-scheme: dark)")
  .addEventListener("change", e => {
    this.setColorScheme(e.matches);
  });

let themePref = localStorage.getItem("theme");
if (themePref === "dark") {
  setColorScheme(true);
} else if (themePref === "default") {
  setColorScheme(false);
} else {
  setColorScheme(window.matchMedia("(prefers-color-scheme: dark)").matches);
}

// cool transition between themes
// have to wait otherwise we get a weird transition on page load
// TODO: this could probably use page load or something instead
//       i.e if people have slow internet, this could be a problem
setTimeout(
  () =>
    (document.querySelector("body").style.transition = "all 0.25s linear 0s"),
  1000,
);
