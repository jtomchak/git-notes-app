import React, { Component } from "react";
import { Link, Route, Switch } from "react-router-dom";
import { Navbar, Nav, NavItem } from "react-bootstrap";

import Routes from "./Routes";
import RouteNavItem from "./components/RouteNavItem";
import "./App.css";

class App extends Component {
  state = {
    isAuthenticated: false
  };

  //successful login
  userHasAuthenticated = authenticated => {
    this.setState({ isAuthenticated: authenticated });
  };

  //log user out
  handleLogout = event => {
    this.userHasAuthenticated(false);
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
              {this.state.isAuthenticated ? (
                <NavItem onClick={this.handleLogout}>Logout</NavItem>
              ) : (
                [
                  <RouteNavItem key={1} href="/signup">
                    {" "}
                    Signup
                  </RouteNavItem>,
                  <RouteNavItem key={2} href="/login">
                    Login{" "}
                  </RouteNavItem>
                ]
              )}
            </Nav>
          </Navbar.Collapse>
        </Navbar>
        <Routes childProps={childProps} />
      </div>
    );
  }
}

export default App;
