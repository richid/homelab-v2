(() => {
  const KEY = "cp-collapsed-groups";

  const load = () => {
    try {
      return new Set(JSON.parse(localStorage.getItem(KEY) || "[]"));
    } catch (error) {
      console.warn("collapse: cannot read the saved groups", error);
      return new Set();
    }
  };

  const save = (groups) => {
    try {
      localStorage.setItem(KEY, JSON.stringify([...groups]));
    } catch (error) {
      console.warn("collapse: cannot save the groups", error);
    }
  };

  const collapsed = load();

  const nameOf = (header) => header.textContent.trim();

  const searching = () => {
    const input = document.querySelector(".search-bar input");
    return Boolean(input && input.value);
  };

  const apply = () => {
    const showAll = searching();
    document.querySelectorAll(".group-title").forEach((header) => {
      const hide = !showAll && collapsed.has(nameOf(header));
      header.classList.toggle("cp-collapsed", hide);
      header.setAttribute("role", "button");
      header.setAttribute("aria-expanded", String(!hide));
      if (!header.hasAttribute("tabindex")) {
        header.tabIndex = 0;
      }
      const parent = header.parentElement;
      if (parent && parent.classList.contains("column") && !header.classList.contains("column")) {
        parent.classList.toggle("cp-group-collapsed", hide);
        return;
      }
      let sibling = header.nextElementSibling;
      while (sibling && !sibling.classList.contains("group-title")) {
        sibling.classList.toggle("cp-hidden", hide);
        sibling = sibling.nextElementSibling;
      }
    });
  };

  const toggle = (header) => {
    const name = nameOf(header);
    if (collapsed.has(name)) {
      collapsed.delete(name);
    } else {
      collapsed.add(name);
    }
    save(collapsed);
    apply();
  };

  document.addEventListener("click", (event) => {
    const header = event.target.closest && event.target.closest(".group-title");
    if (header) {
      toggle(header);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key !== "Enter" && event.key !== " ") {
      return;
    }
    const header = event.target.closest && event.target.closest(".group-title");
    if (header) {
      event.preventDefault();
      toggle(header);
    }
  });

  let queued = false;
  const schedule = () => {
    if (queued) {
      return;
    }
    queued = true;
    requestAnimationFrame(() => {
      queued = false;
      apply();
    });
  };

  const start = () => {
    new MutationObserver(schedule).observe(document.body, { childList: true, subtree: true });
    apply();
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
