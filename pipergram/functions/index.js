const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
 
exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate( async (snapshot, context) => {
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        //create followed user's posts ref
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .doc(userId)
            .collection('userPosts');

        //create following user's timeline ref
        const timelinePostsRef = admin  
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts');

        // get followed user posts
        const querySnapshot = await followedUserPostsRef.get(); 

        // Add each user post to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        })
    });

exports.onDeleteFollower = functions.firestore
        .document("/followers/{userId}/userFollowers/{followerId}")
        .onDelete(async (snapshot, context) => {

            const userId = context.params.userId;
            const followerId = context.params.followerId;

            const timelinePostsRef = admin  
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where("ownerId", "==", userId);

            const querySnapshot = await timelinePostsRef.get();
            querySnapshot.forEach(doc => {
                if(doc.exists) {
                    doc.ref.delete();
                }
            })
            
        })

//add post to timeline when post created
exports.onCreatePost = functions.firestore
        .document('/posts/{userId}/userPosts/{postId}')
        .onCreate(async (snapshot, context) => {
            const postCreated = snapshot.data();
            const userId = context.params.userId;
            const postId = context.params.postId;
        
        //get followers of user who made the post
        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        //add newpost to each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin 
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);
        });
        });

exports.onUpdate = functions.firestore
.document('/posts/{userId}/userPosts/{postId}')
.onUpdate(async (change, context) => {
   const postUpdated = change.after.data();
   const userId = context.params.userId;
   const postId = context.params.postId;

   //get followers of user who made the post
   const userFollowersRef = admin.firestore()
   .collection('followers')
   .doc(userId)
   .collection('userFollowers');

   const querySnapshot = await userFollowersRef.get();

     //update eachpost in each follower's timeline
     querySnapshot.forEach(doc => {
        const followerId = doc.id;

        admin 
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .doc(postId)
            .get().then(doc => {
                if(doc.exists){
                    doc.ref.update(postUpdated);
                }
            })
    });

});

exports.onDeletePost = functions.firestore
.document('/posts/{userId}/userPosts/{postId}')
.onDelete(async (snapshot, context) => {
    const userId = context.params.userId;
    const postId = context.params.postId;
 
    //get followers of user who made the post
    const userFollowersRef = admin.firestore()
    .collection('followers')
    .doc(userId)
    .collection('userFollowers');
 
    const querySnapshot = await userFollowersRef.get();
 
      //delete eachpost in each follower's timeline
      querySnapshot.forEach(doc => {
         const followerId = doc.id;
 
         admin 
             .firestore()
             .collection('timeline')
             .doc(followerId)
             .collection('timelinePosts')
             .doc(postId)
             .get().then(doc => {
                 if(doc.exists){
                     doc.ref.delete();
                 }
             })
     });
});

exports.onCreateActivityFeedItem = functions.firestore
    .document('feed/{userId}/feedItems/{activityFeedItem}')
    .onCreate(async (snapshot, context) => {
        
        //get user connctd to feed
        const userId = context.params.userId;

        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        //if they have notif token (check)
        const androidNotificationToken = doc.data().androidNotificationToken;
        const createdActivityFeedItem = snapshot.data();
        if(androidNotificationToken){
            sendNotification(androidNotificationToken, createdActivityFeedItem);
        }else{

        }

        function sendNotification(androidNotificationToken, activityFeedItem) {
            let body;

            //switch btw values based on type of notif
            switch (activityFeedItem.type) {
                case "comment":
                    body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
                    break;
                case "like":
                    body = `${activityFeedItem.username} liked your post`;
                    break;
                case "follow":
                    body = `${activityFeedItem.username} started following you`;
                    break;
            
                default:
                    break;
            }

            //create msg for push notif
            const message = {
                notification: { body },
                token: androidNotificationToken,
                data: { recipient: userId}
            };

            //send msg with admin.messaging
            admin
                .messaging()
                .send(message)
                .then(response => {
                    console.log("successfully sent msg", response);
                })
                .catch(error => {
                    console.log("Error sending msg", error);
                })
        }
    })

