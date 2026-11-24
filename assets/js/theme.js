// Light/dark theme. The default is the system setting (prefers-color-scheme,
// handled purely in CSS). The toggle stores an explicit choice in
// localStorage; choosing the same as the system clears it, so the site
// follows the system again.
//
// Loaded synchronously in <head> so a saved choice applies before first paint.
(function () {
  var KEY = "theme";
  var root = document.documentElement;
  var media = window.matchMedia("(prefers-color-scheme: dark)");

  try {
    var saved = localStorage.getItem(KEY);
    if (saved === "light" || saved === "dark") root.dataset.theme = saved;
  } catch (e) { /* storage blocked: follow the system */ }

  function current() {
    return root.dataset.theme || (media.matches ? "dark" : "light");
  }

  document.addEventListener("DOMContentLoaded", function () {
    var button = document.getElementById("theme-toggle");
    if (!button) return;
    button.addEventListener("click", function () {
      var next = current() === "dark" ? "light" : "dark";
      var system = media.matches ? "dark" : "light";
      try {
        if (next === system) {
          delete root.dataset.theme;
          localStorage.removeItem(KEY);
        } else {
          root.dataset.theme = next;
          localStorage.setItem(KEY, next);
        }
      } catch (e) {
        root.dataset.theme = next;
      }
    });
  });
})();
