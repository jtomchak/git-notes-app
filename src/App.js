import React, { Component } from "react";
import { Link, Route, Switch, withRouter } from "react-router-dom";
import { Navbar, Nav, NavItem } from "react-bootstrap";

import Routes from "./Routes";
import RouteNavItem from "./components/RouteNavItem";
import { authUser, signOutUser } from "./libs/awsLib";

import "./App.css";

class App extends Component {
  state = {
    isAuthenticated: false,
    isAuthenticating: true
  };

  //check for auth user and set isAuthenticating to false when done
  async componentDidMount() {
    try {
      if (await authUser()) {
        this.userHasAuthenticated(true);
      }
    } catch (e) {
      console.log(e);
    }
    this.setState({ isAuthenticating: false });
  }

  //successful login
  userHasAuthenticated = authenticated => {
    this.setState({ isAuthenticated: authenticated });
  };

  //log user out
  handleLogout = event => {
    //remove auth from localStorage
    signOutUser();
    this.userHasAuthenticated(false);
    this.props.history.push("/login");
  };

  render() {
    const childProps = {
      isAuthenticated: this.state.isAuthenticated,
      userHasAuthenticated: this.userHasAuthenticated
    };
    return (
      !this.state.isAuthenticating && (
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
      )
    );
  }
}

export default withRouter(App);
