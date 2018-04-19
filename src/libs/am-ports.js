import { invokeApig } from "../libs/awsLib";

export let sendData;

export const initPorts = context => ports => {
  ports.outgoingData.subscribe(msg => {
    switch (msg.tag) {
      case "FETCH_NOTES":
        invokeApig({ path: "/notes", queryParams: { limit: 5 } })
          .then(results => sendData({ tag: "NotesLoaded", data: results }))
          .catch(e => console.log(e));
        break;
      case "ERROR_LOG_REQUESTED":
        console.log(msg.data);
        break;
      case "REDIRECT_TO":
        context.router.history.push(msg.data);
        break;
      default:
        return null;
    }
  });

  sendData = ports.incomingData.send;
};
