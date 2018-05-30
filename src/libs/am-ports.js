import { invokeApig } from "../libs/awsLib";

export let sendData;

const fileUploadReader = (id, fn) => {
  let node = document.getElementById(id);
  if (node === null) {
    return;
  }

  let file = node.files[0];
  let reader = new FileReader();

  reader.onload = function(event) {
    //event target is the resulting file
    let base64encoded = event.target.result;
    //invoke callback once content has been loaded
    fn({ content: base64encoded, fileName: file.name });
  };

  //connect to file from input passed into function
  reader.readAsDataURL(file);
};

export const initPorts = context => ports => {
  ports.outgoingData.subscribe(msg => {
    switch (msg.tag) {
      case "FETCH_NOTES":
        invokeApig({ path: "/notes", queryParams: { limit: 5 } })
          .then(results => sendData({ tag: "NOTES_LOADED", data: results }))
          .catch(e => console.log(e));
        break;
      case "ERROR_LOG_REQUESTED":
        console.log(msg.data);
        break;
      case "REDIRECT_TO":
        context.router.history.push(msg.data);
        break;
      case "File_SELECTED":
        function sendReadFile(file) {
          sendData({
            tag: "FILE_CONTENT_READ",
            data: file
          });
        }
        fileUploadReader(msg.data, sendReadFile);
        break;
      default:
        return null;
    }
  });

  sendData = ports.incomingData.send;
};
