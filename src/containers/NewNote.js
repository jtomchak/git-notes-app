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

    this.file = null;

    this.state = {
      isLoading: null,
      content: ""
    };
  }

  validateForm() {
    return this.state.content.length > 0;
  }

  handleChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  };

  handleFileChange = event => {
    this.file = event.target.files[0];
  };

  handleSubmit = async event => {
    event.preventDefault();

    if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
      alert("Please pick a file smaller than 5MB");
      return;
    }

    this.setState({ isLoading: true });

    try {
      const uploadedFilename = this.file ? (await s3Upload(this.file)).Location : null;
      await this.createNote({
        content: this.state.content,
        attachment: uploadedFilename
      });
      this.props.history.push("/");
    } catch (e) {
      console.log(e);
      this.setState({ isLoading: false });
    }
  };

  createNote(note) {
    return invokeApig({
      path: "/notes",
      method: "POST",
      body: note
    });
  }

  render() {
    return (
      <div className="NewNote">
        <Elm src={Main} ports={initPorts(this.context)} flags={{ route: this.props.match.url }} />
        <form onSubmit={this.handleSubmit}>
          <FormGroup controlId="content">
            <FormControl
              onChange={this.handleChange}
              value={this.state.content}
              componentClass="textarea"
            />
          </FormGroup>
          <FormGroup controlId="file">
            <ControlLabel>Attachment</ControlLabel>
            <FormControl onChange={this.handleFileChange} type="file" />
          </FormGroup>
          <LoaderButton
            block
            bsStyle="primary"
            bsSize="large"
            disabled={!this.validateForm()}
            type="submit"
            isLoading={this.state.isLoading}
            text="Create"
            loadingText="Creating…"
          />
        </form>
      </div>
    );
  }
}

//required to pass context.router as props to Elm
NewNote.contextTypes = {
  router: PropTypes.object.isRequired
};
