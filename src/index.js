import React from "react";
import ReactDOM from "react-dom";
import { BrowserRouter as Router } from "react-router-dom";
import "bootstrap/dist/css/bootstrap.css";
// import "@fortawesome/fontawesome-free/css/all.css";
// import "@fortawesome/fontawesome-free/js/all";

import "./index.scss";
import App from "./App";
import registerServiceWorker from "./registerServiceWorker";

import CustomSquare from "./CustomSquare";
import MarkdownText from "./MarkdownText";

ReactDOM.render(
  <Router>
    <App />
  </Router>,
  document.getElementById("root")
);
registerServiceWorker();
CustomSquare.init();
MarkdownText.init();
