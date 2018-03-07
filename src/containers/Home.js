import React, { Component } from "react";
import { ListGroupItem } from "react-bootstrap";
import { invokeApig } from "../libs/awsLib";
import Elm from "../libs/react-elm-components";
import { Lander } from "../elm/Lander";
import { ElmHome } from "../elm/Home";
import "./Home.css";

export default class Home extends Component {
  constructor(props) {
    super(props);

    this.state = {
      isLoading: true
    };
  }

  async componentDidMount() {
    // if (!this.props.isAuthenticated) {
    //   return;
    // }
    // try {
    //   const results = await this.notes();
    //   this.setState({ notes: results });
    // } catch (e) {
    //   alert(e);
    // }
    // this.setState({ isLoading: false });
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
  };

  render() {
    return (
      <div className="Home">
        {this.props.isAuthenticated ? (
          <Elm src={ElmHome} ports={this.setupPorts} />
        ) : (
          <Elm src={Lander} />
        )}
      </div>
    );
  }
}
