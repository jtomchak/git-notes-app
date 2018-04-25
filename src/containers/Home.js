import React, { Component } from "react";
import PropTypes from "prop-types";
import Elm from "../libs/react-elm-components";
import { sendData, initPorts } from "../libs/am-ports";
import { Main } from "../elm/Main";
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
        <Elm src={Main} ports={initPorts(this.context)} flags={{ route: this.props.match.url }} />
      </div>
    );
  }
}

Home.contextTypes = {
  router: PropTypes.object.isRequired
};
