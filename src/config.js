export default {
  s3: {
    BUCKET: "jtnotes-app-upload"
  },
  MAX_ATTACHMENT_SIZE: 5000000,
  apiGateway: {
    URL: "https://7es1qmxwrh.execute-api.us-west-2.amazonaws.com/prod",
    REGION: "us-west-2"
  },
  cognito: {
    USER_POOL_ID: "us-west-2_GViIn0OhN",
    APP_CLIENT_ID: "3tj64hhv0vr5qliob34g9hhf79",
    REGION: "us-west-2",
    IDENTITY_POOL_ID: "us-west-2:327f8582-38c2-45cf-ae5b-d00cd889c28b"
  }
};
