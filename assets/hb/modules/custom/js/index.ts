// This script will be compiled into the JS bundle automatically.
console.log("✅ Random citation script loaded");

// Random citation (no dependencies)
document.addEventListener("DOMContentLoaded", () => {
  const container = document.querySelector<HTMLElement>(".js-random-citation");
  if (!container) return;

  const categories = container.querySelectorAll<HTMLElement>(
    ".citation-category"
  );
  if (!categories.length) return;

  // 1️⃣ Pick a random category
  const category =
    categories[Math.floor(Math.random() * categories.length)];

  const title = container.querySelector<HTMLElement>("#citation-title");
  const blockquote = container.querySelector<HTMLElement>("#citation-content");

  if (!title || !blockquote) return;

  title.textContent = category.dataset.title ?? "";

  // 2️⃣ Pick a random item inside the category
  const items = category.querySelectorAll<HTMLElement>("div");
  if (!items.length) return;

  const chosen = items[Math.floor(Math.random() * items.length)];

  const text = chosen.dataset.text ?? "";
  const author = chosen.dataset.author;

  blockquote.innerHTML = `
    “${text}”
    ${author ? `<footer>— ${author}</footer>` : ""}
  `;
});
// End of random citation