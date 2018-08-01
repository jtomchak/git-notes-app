import { invokeApig, s3Upload } from "../libs/awsLib";
import resizeImage from "../libs/resize";

export let sendData;

const fileUploadReader = (id, fn) => {
  let node = document.getElementById(id);
  if (node === null) {
    return;
  }

  let file = node.files[0];
  resizeImage({
    file: file,
    maxSize: 900
  })
    .then(function(resizedImage) {
      console.log("upload resized image");
      //invoke callback once content has been loaded
      fn({
        content: resizedImage,
        name: file.name,
        fileType: file.type,
        size: file.size
      });
    })
    .catch(function(err) {
      console.error(err);
    });
};

const postNote = async function(content, attachment) {
  try {
    const uploadedFilename = attachment
      ? (await s3Upload(attachment)).Location
      : null;
    return invokeApig({
      path: "/notes",
      method: "POST",
      body: {
        content: content,
        attachment: uploadedFilename
      }
    });
  } catch (e) {
    console.log(e);
  }
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
      case "CREATE_NEW_NOTE":
        const { noteContent, image } = msg.data;
        console.log(msg.data);
        postNote(noteContent, image)
          .then(result => {
            context.router.history.push("/");
            console.log(result);
          })
          .catch(err => console.log(err));
        break;
      default:
        return null;
    }
  });

  sendData = ports.incomingData.send;
};
