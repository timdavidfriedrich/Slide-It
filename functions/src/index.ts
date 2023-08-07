import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {initializeApp} from "firebase-admin/app";
import {getMessaging} from "firebase-admin/messaging";

// import appRefreshToken from "./refreshToken.json";

initializeApp();
// initializeApp({credential: refreshToken("./refreshToken.json")});

// initializeApp({
//   credential: refreshToken({
//     type: "service_account",
//     project_id: "slide-it-rating",
//     private_key_id: "a81c2c69d20f30a85d7e13a9bc9d090f4b0b6c52",
//     private_key:
//       "-----BEGIN PRIVATE KEY-----" +
//       "\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC2sH7U2tI5UjjN" +
//       "\ndXV9219u6oqFa4qeglVbgU+GdSJUWu6FdH8uiivlU2v2O2zHqtWABWuo6+mqfctO" +
//       "\nONqRbw/wXBpagUzimyPabmEYYFFTMidRgUFocte3I+MCmYXMQO9R3XW1QjMg0kE2" +
//       "\n5vIjFYnTR9CkUo/AtkdSI55XvNfMwZ/NYi1XGEZUuOcQ+BCat2ks3Y8WjJ8kTYs8" +
//       "\nZM0leicgkK5hlJgKpqub5iaBcPik7SIVNxEo+iMJpvxQk4nYfBs8XFnDABrnmci/" +
//       "\neBDF+kZVOLP/lCWpBK9KavObyDSkz6mnJHyrH22AJW+BDPI5ihKn31Q+Uo7Zrqhr" +
//       "\nG9rc5w2fAgMBAAECggEAVAhsVrmOwIonEa7pS+qYA7uD2yoj+ZRm8e/Rpj4D+/xV" +
//       "\nwfJbvAsXdOWCACHGgDN/AGO96VYWxfMWDNWPCB2nnb6n6qCWPpfxDnz+UYmgbt3f" +
//       "\ngxiq/wHwYs/xkFUQ2+q0ipoNFkKspPjBwaDKmUPDgXmDqcpGUHUn6kry/1WgiBBz" +
//       "\nSm5FnW3MxOBkX4F+zCNIZSJRt8HNqw21agDSm3x+GLCzQsGogUNjAYvkzq4mX76U" +
//       "\npHVCVYvlRIFsSVe6m8Be1LAgF5C1KqpZZjPleK8emrNgvd2kVbePj0jIPyzhaEQj" +
//       "\nt0wDR+ObAei0BeNm4l9cvbp8c21wCBioee0d/p4JaQKBgQDeeeSLTpi9VNGX10p2" +
//       "\nCKRTPTjK4g7EIJh6OT7yF+lyO4250IjzJGa4IDFfG0IBYlu89xxVR2eXBDAugkw3" +
//       "\nMBswH+9A2IxJr+Drkrh27Cqd5J8Af3yJn490qOeTvtH6n5qUwvnQIYWsMmPAPOiW" +
//       "\n/p0/YJHq0+2+Ntzr6DKzQ6XGhwKBgQDSN9B3BvqTgL66Rh/fHSQpwep0SOkqy5AA" +
//       "\ntKCiWkCzj0w8B0LXQ0Pkt0iesy2I0ybAZ1H/kcc+B8J0J/sj54WpyOKSMMglhBrH" +
//       "\nIgu7SbhLKvpJfr0ce1sAv/AJE/f3gjPuWr2XeTujNATzlbBA8L59vq7cpFufYZtC" +
//       "\nNgSQUmIuKQKBgHxfrJLsp5sA9gNrCmeeQS9/xGY3poWiq1t48WWqVInWHU9J86Xq" +
//       "\nLbq11KQUuvvHHv4vL5nFR3Y3kzANC8q2jByFXd3ksdjoCFfqOFHTiaenjfRbUSYn" +
//       "\nG63eV0hTn1P7MhIERmBCvVYc/YMVCfqP8RzjQfAD9p8mUK9Zqi5pnR21AoGAbA70" +
//       "\nwbp8o8XSRL43M+Eu7agYdJ3l/XGWHEa9K7do+uP2NAUnfq+8/pyYX7uK9IJVsSFr" +
//       "\nLQwqduBWPI8wsUwZkSUKEkuxFlfJzALcNPG4Iit9bLoRS8q9BK2lHYV+OWRcfXF3" +
//       "\nc52F4majBPM1HqyhvtF94T07O7pYrLhHsEgo38ECgYAllwYTPJFAH2QDqQ+gCHK8" +
//       "\nSsXXPjphWsSZRJl4HlmSog3otLXloYVyl6pArExn3/c1f+yc0nv+BEp/Os+QWseK" +
//       "\nWiAbmYtW6Ykm88qqlPI24Xw0z3IKXHbKAMzWu7zS4cMhNYfxYT9t0zK2ckAnVRj7" +
//       "\nxghPnRBdxxF5vIMHTI8Asg==\n-----END PRIVATE KEY-----\n",
//     client_email:
//       "firebase-adminsdk-uaee0@slide-it-rating.iam.gserviceaccount.com",
//     client_id: "108940236545426031108",
//     auth_uri: "https://accounts.google.com/o/oauth2/auth",
//     token_uri: "https://oauth2.googleapis.com/token",
//     auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
//     client_x509_cert_url:
//       "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-uaee0%40slide-it-rating.iam.gserviceaccount.com",
//     universe_domain: "googleapis.com",
//   }),
//   // databaseURL: "https://slide-it-rating.firebaseio.com",
// });

export const sendNotificationAfterUpdate = onDocumentUpdated(
  "groups/{groupId}",
  (event) => {
    console.log(event);
    console.log("sendNotificationAfterUpdate was called");
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No data associated with the event");
      return;
    }
    const data = snapshot.after.data();

    const groupId = event.params.groupId;
    const userName = data.userName;
    const itemName = data.itemName;
    console.log("initialized variables");

    const payload = {
      notification: {
        title: `${userName} wartet auf Bewertungen!`,
        body: `${itemName}`,
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    console.log("tries to send notification...");
    return getMessaging().sendToTopic(groupId, payload);
  }
);

// import * as functions from "firebase-functions";
// import * as admin from "firebase-admin";

// import serviceAccount from "./token.json";

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount.toString()),
// });

// exports.sendNotificationAfterItemAdded = functions.firestore
//   .document("groups/{groupId}")
//   .onUpdate((snapshot, context) => {
//     const userName = "DMAP";
//     const itemName =
//       "Brokkolipfanne mit Tomaten-Mozarella-Salat und Erdbeerkäse";

//     const payload = {
//       notification: {
//         title: `${userName} wartet auf Bewertungen!`,
//         body: `${itemName}`,
//         clickAction: "FLUTTER_NOTIFICATION_CLICK",
//       },
//     };

//     admin
//       .messaging()
//       .sendToTopic("group--90a8b6af-1bfb-4290-9fc6-122a7e8491bb", payload);
//     // admin.messaging().sendToTopic(context.params.groupId, payload);
//   });
