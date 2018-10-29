import { Main } from "./elm/Main";
import "bootstrap/dist/css/bootstrap.css";
import "@fortawesome/fontawesome-free/css/all.css";
import "@fortawesome/fontawesome-free/js/all";

import "./index.scss";
import registerServiceWorker from "./registerServiceWorker";

import CustomSquare from "./CustomSquare";
import MarkdownText from "./MarkdownText";

Main.embed(document.getElementById("root"));

registerServiceWorker();
CustomSquare.init();
MarkdownText.init();
