import CustomElements from "./libs/CustomElements";

const load = () => {
  return Promise.all([
    import(/* webpackChunkName: "codemirror-base" */ "codemirror/lib/codemirror"),
    import(/* webpackChunkName: "codemirror-base", webpackMode: "eager" */ "codemirror/lib/codemirror.css"),
    import(/* wepackChunkName: "markdown-text-base", webpackMode: "eager" */ "./MarkdownText.scss")
  ]).then(([CodeMirror]) => CodeMirror);
};

const init = () => {
  // Create a class for the element
  return load().then(CodeMirror => {
    CustomElements.define(
      "markdown-text",
      HTMLElement =>
        class MarkdownText extends HTMLElement {
          constructor() {
            // Always call super first in constructor
            super();
          }

          get markdownValue() {
            return this._markdownValue;
          }

          set markdownValue(value) {
            if (value !== null && value !== this._markdownValue) {
              this._markdownValue = value;
              if (!this._markdownInstance) return;
              this._markdownInstance.setValue(value);
              // this._markdownInstance.setCursor(
              //   this._markdownInstance.lineCount(),
              //   0
              // );
            }
          }

          connectedCallback() {
            console.log("Custom markdown element added to page.");
            this._markdownInstance = CodeMirror(this, {
              mode: "markdown",
              lineNumbers: true,
              value: this._markdownValue,
              linewrapping: true,
              autofocus: true,
              direction: "ltr"
            });

            //onChange Event
            this._markdownInstance.on("changes", () => {
              console.log(this._markdownInstance.getValue());
              this._markdownValue = this._markdownInstance.getValue();
              this.dispatchEvent(new CustomEvent("markdownTextChange"));
            });
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
