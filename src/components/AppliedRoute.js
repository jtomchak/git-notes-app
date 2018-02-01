import React from "react";
import { Route } from "react-router-dom";

const AppliedRoute = ({
  component: ComponentToRender,
  props: childProps,
  ...rest
}) => (
  <Route
    {...rest}
    render={props => <ComponentToRender {...props} {...childProps} />}
  />
);

export default AppliedRoute;
