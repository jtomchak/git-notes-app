import React, { Component } from "react";
import { FormGroup, FormControl, ControlLabel } from "react-bootstrap";
import LoaderButton from "../components/LoaderButton";
import { invokeApig, s3Upload } from "../libs/awsLib";

//--> Required for Elm Render
import PropTypes from "prop-types";
import Elm from "../libs/react-elm-components";
import { sendData, initPorts } from "../libs/am-ports";
import { Main } from "../elm/Main";
//<--- End of Elm Requirements

import config from "../config";
import "./Notes.css";

export default class Notes extends Component {
  constructor(props) {
    super(props);

    this.file = null;

    this.state = {
      isLoading: null,
      isDeleting: null,
      note: null,
      content: ""
    };
  }

  async componentDidMount() {
    try {
      const results = await this.getNote();
      this.setState({
        note: results,
        content: results.content
      });
    } catch (e) {
      alert(e);
    }
  }

  getNote() {
    return invokeApig({ path: `/notes/${this.props.match.params.id}` });
  }

  saveNote(note) {
    return invokeApig({
      path: `/notes/${this.props.match.params.id}`,
      method: "PUT",
      body: note
    });
  }

  validateForm() {
    return this.state.content.length > 0;
  }

  formatFilename(str) {
    return str.length < 50
      ? str
      : str.substr(0, 20) + "..." + str.substr(str.length - 20, str.length);
  }

  handleChange = event => {
    this.setState({
      [event.target.id]: event.target.value
    });
  };

  handleFileChange = event => {
    this.file = event.target.files[0];
  };

  //we need to delete the attachment when we upload a new one
  handleSubmit = async event => {
    let uploadedFilename;

    event.preventDefault();

    if (this.file && this.file.size > config.MAX_ATTACHMENT_SIZE) {
      alert("Please pick a file smaller than 5MB");
      return;
    }

    this.setState({ isLoading: true });

    try {
      if (this.file) {
        uploadedFilename = (await s3Upload(this.file)).Location;
      }

      await this.saveNote({
        ...this.state.note,
        content: this.state.content,
        attachment: uploadedFilename || this.state.note.attachment
      });
      this.props.history.push("/");
    } catch (e) {
      console.log(e);
      this.setState({ isLoading: false });
    }
  };

  deleteNote() {
    return invokeApig({
      path: `/notes/${this.props.match.params.id}`,
      method: "DELETE"
    });
  }
  handleDelete = async event => {
    event.preventDefault();
    const confirmed = window.confirm(
      "Are you sure you want to delete this note?"
    );
    if (!confirmed) {
      return;
    }
    this.setState({ isDeleting: true });
    try {
      await this.deleteNote();
      this.props.history.push("/");
    } catch (e) {
      console(e);
      this.setState({ isDeleting: false });
    }
  };

  render() {
    return (
      <div className="Notes">
        <Elm
          src={Main}
          ports={initPorts(this.context)}
          flags={{ route: this.props.match.url }}
        />
      </div>
    );
  }
}

//required to pass context.router as props to Elm
Notes.contextTypes = {
  router: PropTypes.object.isRequired
};
