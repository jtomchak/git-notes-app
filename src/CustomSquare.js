import CustomElements from "./libs/CustomElements";

const init = () => {
  // Create a class for the element
  return CustomElements.define(
    "custom-square",
    HTMLElement =>
      class Square extends HTMLElement {
        // Specify observed attributes so that
        // attributeChangedCallback will work
        static get observedAttributes() {
          return ["w", "l"];
        }

        constructor() {
          // Always call super first in constructor
          super();

          const shadow = this.attachShadow({ mode: "open" });

          const div = document.createElement("div");
          const style = document.createElement("style");
          shadow.appendChild(style);
          shadow.appendChild(div);
        }

        connectedCallback() {
          console.log("Custom square element added to page.");
          updateStyle(this);
        }

        disconnectedCallback() {
          console.log("Custom square element removed from page.");
        }

        adoptedCallback() {
          console.log("Custom square element moved to new page.");
        }

        attributeChangedCallback(name, oldValue, newValue) {
          console.log("Custom square element attributes changed.");
          updateStyle(this);
        }
      }
  );
};

export default { init };

function updateStyle(elem) {
  const shadow = elem.shadowRoot;
  const childNodes = Array.from(shadow.childNodes);
  const lAttribute = parseInt(elem.getAttribute("l"), 10);
  childNodes.forEach(childNode => {
    if (childNode.nodeName === "STYLE") {
      console.log(lAttribute);
      childNode.textContent = `
          div {
            width: ${elem.getAttribute("l")}px;
            height: ${elem.getAttribute("l")}px;
            background-color: ${elem.getAttribute("c")};
          }
        `;
    }
  });
}
