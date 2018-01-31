import React, { Component } from "react";
import { Link, Route, Switch } from "react-router-dom";
import { Navbar, Nav } from "react-bootstrap";

import Routes from "./Routes";
import RouteNavItem from "./components/RouteNavItem";
import "./App.css";

class App extends Component {
  state = {
    isAuthenticated: false
  };
  userHasAuthenticated = authenticated => {
    this.setState({ isAuthenticated: authenticated });
  };
  render() {
    const childProps = {
      isAuthenticated: this.state.isAuthenticated,
      userHasAuthenticated: this.userHasAuthenticated
    };
    return (
      <div className="App container">
        <Navbar fluid collapseOnSelect>
          <Navbar.Header>
            <Navbar.Brand>
              <Link to="/">Git Notes</Link>
            </Navbar.Brand>
            <Navbar.Toggle />
          </Navbar.Header>
          <Navbar.Collapse>
            <Nav pullRight>
              <RouteNavItem href="/signup">Signup</RouteNavItem>
              <RouteNavItem href="/login">Login</RouteNavItem>
            </Nav>
          </Navbar.Collapse>
        </Navbar>
        <Routes childProps={childProps} />
      </div>
    );
  }
}

export default App;
