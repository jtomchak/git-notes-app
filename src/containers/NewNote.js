import React, { Component } from "react";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import { invokeApig, s3Upload } from "../libs/awsLib";

//--> Required for Elm Render
import PropTypes from "prop-types";
import Elm from "../libs/react-elm-components";
import { sendData, initPorts } from "../libs/am-ports";
import { Main } from "../elm/Main";
//<--- End of Elm Requirements

import LoaderButton from "../components/LoaderButton";
import config from "../config";
import "./NewNote.css";

export default class NewNote extends Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    sendData({ tag: "IS_AUTHENTICATED", data: this.props.isAuthenticated });
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.isAuthenticated !== this.props.isAuthenticated) {
      sendData({ tag: "IS_AUTHENTICATED", data: this.props.isAuthenticated });
    }
  }

  render() {
    return (
      <div className="NewNote">
        <Elm src={Main} ports={initPorts(this.context)} />
      </div>
    );
  }
}

//required to pass context.router as props to Elm
NewNote.contextTypes = {
  router: PropTypes.object.isRequired
};
