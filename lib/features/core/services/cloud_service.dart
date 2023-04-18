import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/core/providers/data_provider.dart';
import 'package:rating/features/core/services/group.dart';

class CloudService {
  static final _userCollection = FirebaseFirestore.instance.collection("users");
  static final _groupCollection = FirebaseFirestore.instance.collection("groups");

  static Future saveUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    // final AppUser appUser = AppUser.instance;
    await _userCollection.doc(user!.uid).set({
      // ! saveUserData only gets called when the user is signed in for the first time (or when the user data is deleted)
      // ! => token is always the same and no newer tokens are added
      "firebaseMessagingTokens": FieldValue.arrayUnion(List<String?>.from([await FirebaseMessaging.instance.getToken()])),
      "groups": [user.uid],
    }, SetOptions(merge: true));
    Log.hint("User data saved (UID: ${user.uid}).");
  }

  static Future loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    // final AppUser appUser = AppUser.instance;
    DocumentSnapshot snapshot = await _userCollection.doc(user!.uid).get();
    if (!snapshot.exists) {
      // appUser.signOut();
      saveUserData();
      return;
    }
    Log.hint("User data loaded (UID: ${user.uid}).");
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    // appUser.loadFromJson(data);
  }

  static Future<List<Group>> getGroupData() async {
    List<Group> groups = [];
    final QuerySnapshot<Map<String, dynamic>> rawData = await _groupCollection.get();
    final rawGroups = rawData.docs.map((doc) => doc.data()).toList();
    for (Map<String, dynamic> rawGroup in rawGroups) {
      groups.add(Group.fromJson(rawGroup));
    }
    return groups;
  }

  static Future createGroup(String name) async {
    final Group group = Group(name: name);
    await _groupCollection.doc(group.id).set(group.toJson(), SetOptions(merge: true));
    await joinGroup(group.id);
    Provider.of<DataProvider>(Global.context, listen: false).loadData();
  }

  static Future joinGroup(String id) async {
    final User? user = FirebaseAuth.instance.currentUser;
    await _userCollection.doc(user!.uid).set({
      "groups": FieldValue.arrayUnion(List<String>.from([id])),
    }, SetOptions(merge: true));
    FirebaseMessaging.instance.subscribeToTopic(id);
    Provider.of<DataProvider>(Global.context, listen: false).loadData();
  }
}
