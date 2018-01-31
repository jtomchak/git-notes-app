import React from "react";
import { Route, Switch } from "react-router-dom";

import Home from "./containers/Home";
import Login from "./containers/Login";
import NotFound from "./containers/NotFound";

const Routes = ({ childProps }) => (
  <Switch>
    <Route path="/" exact component={Home} props={childProps} />
    <Route path="/login" exact component={Login} props={childProps} />

    {/* Finally, catch all unmatched routes */}
    <Route component={NotFound} />
  </Switch>
);

export default Routes;
