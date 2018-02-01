import { CognitoUserPool } from "amazon-cognito-identity-js";
import AWS from "aws-sdk";
import config from "../config";

//get user from local storage via CognitoUserPool
export async function authUser() {
  const currentUser = getCurrentUser();
  if (currentUser === null) {
    return false;
  }
  await getUserToken(currentUser);
  return true;
}

//clear out user
export function signOutUser() {
  const currentUser = getCurrentUser();
  if (currentUser !== null) {
    currentUser.signOut();
  }
}
function getUserToken(currentUser) {
  return new Promise((resolve, reject) => {
    currentUser.getSession(function(err, session) {
      if (err) {
        reject(err);
        return;
      }
      resolve(session.getIdToken().getJwtToken());
    });
  });
}
function getCurrentUser() {
  const userPool = new CognitoUserPool({
    UserPoolId: config.cognito.USER_POOL_ID,
    ClientId: config.cognito.APP_CLIENT_ID
  });
  return userPool.getCurrentUser();
}

const getAwsCredentials = userToken => {
  const authenticator = `cognito-idp.${config.cognito.REGION}.amazonaws.com/${
    config.cognito.USER_POOL_ID
  }`;
  AWS.config.update({ region: config.cognito.REGION });
  AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: config.cognito.IDENTITY_POOL_ID,
    Logins: {
      [authenticator]: userToken
    }
  });
  return AWS.config.credentials.getPromise();
};
