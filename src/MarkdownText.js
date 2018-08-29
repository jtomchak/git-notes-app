import CustomElements from "./libs/CustomElements";

const load = () => {
  return Promise.all([
    import(/* webpackChunkName: "codemirror-base" */ "codemirror/lib/codemirror"),
    import(/* webpackChunkName: "codemirror-base", webpackMode: "eager" */ "codemirror/lib/codemirror.css")
  ]).then(([CodeMirror]) => CodeMirror);
};

const init = () => {
  // Create a class for the element
  return load().then(CodeMirror => {
    CustomElements.define(
      "markdown-text",
      HTMLElement =>
        class MarkdownText extends HTMLElement {
          // Specify observed attributes so that
          // attributeChangedCallback will work
          // static get observedAttributes() {
          //   return ["w", "l"];
          // }

          constructor() {
            // Always call super first in constructor
            super();
            const shadow = this.attachShadow({ mode: "open" });
            const textarea = document.createElement("textarea");
            shadow.appendChild(textarea);

            this._markdownValue = "Oh man!!!!!";
          }

          get markdownValue() {
            return this._markdownValue;
          }

          set markdownValue(value) {
            this._markdownValue = value;
            if (!this._markdown) return;
            this._markdown.value(value);
          }

          connectedCallback() {
            console.log(
              "Custom markdown element added to page.",
              this.shadowRoot.firstChild
            );
            this._markdown = CodeMirror.fromTextArea(
              this.shadowRoot.firstChild
            );
          }

          disconnectedCallback() {
            console.log("Custom markdown element removed from page.");
          }

          adoptedCallback() {
            console.log("Custom markdown element moved to new page.");
          }

          attributeChangedCallback(name, oldValue, newValue) {
            console.log("Custom markdown element attributes changed.");
          }
        }
    );
  });
};
export default { init };
