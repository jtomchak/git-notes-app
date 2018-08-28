import SimpleMDE from "simplemde";
// var simplemde = new SimpleMDE();

class MarkdownText extends HTMLElement {
  constructor() {
    super();
  }
}

customElements.define("markdown-text", MarkdownText);
export default MarkdownText;
