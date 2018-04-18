import React, { Component } from "react";
import Elm from "../libs/react-elm-components";
import { sendData, initPorts } from "../libs/am-ports";
import { ElmHome } from "../elm/Home";
import "./Home.css";

export default class Home extends Component {
  state = {
    isLoading: true
  };

  componentDidMount() {
    sendData({ tag: "IsAuthenticated", data: this.props.isAuthenticated });
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.isAuthenticated !== this.props.isAuthenticated) {
      sendData({ tag: "IsAuthenticated", data: this.props.isAuthenticated });
    }
  }

  render() {
    return (
      <div className="Home">
        <Elm src={ElmHome} ports={initPorts} />
      </div>
    );
  }
}
