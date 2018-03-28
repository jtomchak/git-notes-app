import React, { Component } from "react";
import { ListGroupItem } from "react-bootstrap";
import { invokeApig } from "../libs/awsLib";
import Elm from "../libs/react-elm-components";
import { ElmHome } from "../elm/Home";
import "./Home.css";

export default class Home extends Component {
  state = {
    isLoading: true
  };

  componentDidMount() {
    this.updateAuth(this.props.isAuthenticated);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.isAuthenticated !== this.props.isAuthenticated) {
      this.updateAuth(nextProps.isAuthenticated);
    }
  }

  renderNotesList(notes) {
    return [{}].concat(notes).map(
      (note, i) =>
        i !== 0 ? (
          <ListGroupItem
            key={note.noteId}
            href={`/notes/${note.noteId}`}
            onClick={this.handleNoteClick}
            header={note.content.trim().split("\n")[0]}
          >
            {"Created: " + new Date(note.createdAt).toLocaleString()}
          </ListGroupItem>
        ) : (
          <ListGroupItem key="new" href="/notes/new" onClick={this.handleNoteClick}>
            <h4>
              <b>{"\uFF0B"}</b> Create a new note
            </h4>
          </ListGroupItem>
        )
    );
  }

  //init setup for ports
  setupPorts = ports => {
    ports.fetchNotes.subscribe(path => {
      invokeApig({ path: path, queryParams: { limit: 5 } })
        .then(results => ports.notesLoaded.send(results))
        .catch(e => console.log(e));
    });
    ports.routeTo.subscribe(url => {
      this.props.history.push(url);
    });
    this.updateAuth = ports.isAuthenticated.send;
  };

  render() {
    return (
      <div className="Home">
        <Elm src={ElmHome} ports={this.setupPorts} />
      </div>
    );
  }
}
