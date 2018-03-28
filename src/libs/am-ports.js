import { invokeApig } from "../libs/awsLib";

export let sendData;

export const initPorts = ports => {
  ports.outgoingData.subscribe(msg => {
    switch (msg.tag) {
      case "FetchNotes":
        invokeApig({ path: "/notes", queryParams: { limit: 5 } })
          .then(results => sendData({ tag: "NotesLoaded", data: results }))
          .catch(e => console.log(e));
        break;
      case "ErrorLogRequested":
        console.log(msg.data);
        break;
      case "routeTo":
        //call props.history.push w/ url
        break;
      default:
        return null;
    }
  });

  sendData = ports.incomingData.send;
};
