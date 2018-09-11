import React, { Component } from "react";

export default class extends Component {
  //don't want to have a react rerender on our Elm Component....Ever!
  shouldComponentUpdate() {
    return false;
  }

  //uses the ref callback in React to get the node in order to embed the Elm
  initialize = node => {
    if (node === null) return;
    const app = this.props.src.embed(node, this.props.flags);
    if (typeof this.props.ports !== "undefined") {
      this.props.ports(app.ports);
    }
  };

  render() {
    return React.createElement("div", { ref: this.initialize });
  }
}
