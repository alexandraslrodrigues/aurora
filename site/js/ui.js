/* Small page helpers shared by all pages (no library needed). */
(function (root) {
  "use strict";
  var Aurora = root.Aurora = root.Aurora || {};

  // h("div", {class: "x", onclick: fn}, child1, "text", ...) -> element
  function h(tag, attrs) {
    var el = document.createElement(tag);
    if (attrs) {
      for (var k in attrs) {
        var v = attrs[k];
        if (v === null || v === undefined || v === false) continue;
        if (k === "class") el.className = v;
        else if (k === "html") el.innerHTML = v;
        else if (k === "text") el.textContent = v;
        else if (k.slice(0, 2) === "on" && typeof v === "function") el.addEventListener(k.slice(2), v);
        else if (k === "style" && typeof v === "object") Object.assign(el.style, v);
        else el.setAttribute(k, v === true ? "" : v);
      }
    }
    for (var i = 2; i < arguments.length; i++) append(el, arguments[i]);
    return el;
  }
  function append(el, c) {
    if (c === null || c === undefined || c === false) return;
    if (Array.isArray(c)) { c.forEach(function (x) { append(el, x); }); return; }
    el.appendChild(c instanceof Node ? c : document.createTextNode(String(c)));
  }

  // Segmented buttons. opts: {options:[{value,label,sub,title}], get(), set(v), cls, label}
  // Returns the element; element.sync() refreshes which button is pressed.
  function seg(opts) {
    var wrap = h("div", { class: "seg " + (opts.cls || ""), role: "group", "aria-label": opts.label || null });
    var buttons = opts.options.map(function (o) {
      var b = h("button", { type: "button", "data-v": String(o.value), title: o.title || o.hint || null,
                            onclick: function () { opts.set(o.value); } },
                o.label, o.sub ? h("span", { class: "sub" }, o.sub) : null);
      wrap.appendChild(b);
      return b;
    });
    wrap.sync = function () {
      var cur = String(opts.get());
      buttons.forEach(function (b) { b.setAttribute("aria-pressed", b.getAttribute("data-v") === cur ? "true" : "false"); });
    };
    wrap.sync();
    return wrap;
  }

  // Links inside content open in a new tab
  function externalLinks(el) {
    el.querySelectorAll("a[href^='http']").forEach(function (a) { a.target = "_blank"; a.rel = "noopener"; });
    return el;
  }

  // Info card (definition, images, credits) as an element
  function infoCard(key, opts) {
    var c = Aurora.content.info[key];
    if (!c) return h("div");
    var box = h("div", { class: "info-content" },
      (opts && opts.title) ? h("h2", null, c.title) : null,
      (c.images || []).map(function (src) { return h("img", { src: "img/" + src, alt: c.title, loading: "lazy" }); }),
      h("div", { html: c.body }),
      h("div", { class: "credits", html: c.credits }));
    return externalLinks(box);
  }

  var modal, modalTitle, modalBody;
  function openModal(title, content) {
    modal = modal || document.getElementById("modal");
    modalTitle = modalTitle || document.getElementById("modal-title");
    modalBody = modalBody || document.getElementById("modal-body");
    modalTitle.textContent = title;
    modalBody.innerHTML = "";
    modalBody.appendChild(content);
    externalLinks(modalBody);
    if (typeof modal.showModal === "function") modal.showModal(); else modal.setAttribute("open", "");
    modalBody.scrollTop = 0;
  }
  function closeModal() {
    if (!modal) return;
    if (typeof modal.close === "function") modal.close(); else modal.removeAttribute("open");
  }
  function openInfo(key) {
    var c = Aurora.content.info[key];
    if (c) openModal(c.title, infoCard(key));
  }
  document.addEventListener("click", function (e) {
    var m = document.getElementById("modal");
    if (!m) return;
    if (e.target.closest && e.target.closest("[data-close]")) closeModal();
    else if (e.target === m) closeModal();            // click on the backdrop
  });

  var toastTimer;
  function toast(msg) {
    var t = document.getElementById("toast");
    t.textContent = msg;
    t.classList.add("show");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { t.classList.remove("show"); }, 1800);
  }

  function copyText(text) {
    if (navigator.clipboard && root.isSecureContext) {
      return navigator.clipboard.writeText(text).then(function () { return true; }, function () { return fallbackCopy(text); });
    }
    return Promise.resolve(fallbackCopy(text));
  }
  function fallbackCopy(text) {
    var ta = h("textarea", { style: { position: "fixed", top: "-1000px", opacity: "0" } });
    ta.value = text;
    document.body.appendChild(ta);
    ta.select();
    var ok = false;
    try { ok = document.execCommand("copy"); } catch (e) { ok = false; }
    ta.remove();
    return ok;
  }

  // Storage that never throws (private mode, blocked storage…)
  function store(kind) {
    return {
      get: function (k) { try { var v = root[kind].getItem(k); return v ? JSON.parse(v) : null; } catch (e) { return null; } },
      set: function (k, v) { try { root[kind].setItem(k, JSON.stringify(v)); } catch (e) { /* ignore */ } },
      del: function (k) { try { root[kind].removeItem(k); } catch (e) { /* ignore */ } }
    };
  }

  Aurora.ui = { h: h, seg: seg, infoCard: infoCard, openInfo: openInfo, openModal: openModal, closeModal: closeModal,
                toast: toast, copyText: copyText, externalLinks: externalLinks,
                session: store("sessionStorage"), local: store("localStorage") };
})(window);
