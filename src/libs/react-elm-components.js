import React, { Component } from "react";

export default class extends Component {
  //don't want to have a react rerender on our Elm Component....Ever!
  shouldComponentUpdate() {
    return false;
  }

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
