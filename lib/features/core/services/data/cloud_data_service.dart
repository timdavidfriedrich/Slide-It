import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:log/log.dart';
import 'package:provider/provider.dart';
import 'package:rating/constants/global.dart';
import 'package:rating/features/ratings/models/category.dart';
import 'package:rating/features/core/services/data/data_provider.dart';
import 'package:rating/features/ratings/models/item.dart';
import 'package:rating/features/core/models/app_user.dart';
import 'package:rating/features/social/models/group.dart';
import 'package:rating/features/ratings/models/rating.dart';

class CloudService {
  static CloudService instance = CloudService();

  final _userCollection = FirebaseFirestore.instance.collection("users");
  final _groupCollection = FirebaseFirestore.instance.collection("groups");

  QuerySnapshot<Map<String, dynamic>>? _rawUsersData;
  QuerySnapshot<Map<String, dynamic>>? _rawGroupsData;

  // * Currently, only gets called when user is created, not if he changes his name, avatar or something.
  Future<bool> saveUserData({String? name}) async {
    final User? user = FirebaseAuth.instance.currentUser;
    // final String? firebaseMessagingToken = await FirebaseMessaging.instance.getToken();
    if (user == null) return false;
    AppUser.current = AppUser(
      id: user.uid,
      name: name ?? user.displayName,
      avatarUrl: user.photoURL,
      // firebaseMessagingTokens: firebaseMessagingToken == null ? [] : [firebaseMessagingToken],
    );
    if (AppUser.current == null) return false;
    await _userCollection.doc(user.uid).set(AppUser.current!.toJson(), SetOptions(merge: true));
    Log.hint("User data saved (User ID: ${user.uid}) to cloud.");
    return true;
  }

  Future<void> loadRawData() async {
    await loadRawUsersData();
    await loadRawGroupsData();
  }

  Future<void> loadRawUsersData() async {
    _rawUsersData = await _userCollection.get();
    Log.hint("Loaded raw user data from cloud.");
  }

  Future<void> loadRawGroupsData() async {
    _rawGroupsData = await _groupCollection.get();
    Log.hint("Loaded raw group from cloud.");
  }

  Future<void> loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    Log.debug(user);
    DocumentSnapshot snapshot = await _userCollection.doc(user.uid).get();
    if (!snapshot.exists) {
      saveUserData();
      return;
    }
    AppUser.current = AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
    Log.hint("Loaded User data (UID: ${user.uid}) from cloud.");
  }

  Future<List<Group>> getUserGroups() async {
    List<Group> result = [];

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      if (_rawUsersData == null) await loadRawUsersData();
      if (_rawGroupsData == null) await loadRawGroupsData();

      Map<String, dynamic>? currentRawUsersData = _rawUsersData?.docs.firstWhere((doc) => doc.id == user.uid).data();
      AppUser.current = AppUser.fromJson(currentRawUsersData);
      if (AppUser.current == null) return result;

      List<Group> groups = _rawGroupsData?.docs.map((doc) => Group.fromJson(doc.data())).toList() ?? [];

      for (Group g in groups) {
        if (!AppUser.current!.groupIds.contains(g.id)) continue;
        result.add(g);
      }
    } catch (e) {
      Log.error(e);
    }

    return result;
  }

  Future<List<AppUser>> getKnownUsers() async {
    List<AppUser> result = [];

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    if (_rawUsersData == null) await loadRawUsersData();
    if (_rawGroupsData == null) await loadRawGroupsData();

    List<AppUser> appUsers = _rawUsersData?.docs.map((doc) => AppUser.fromJson(doc.data())).toList() ?? [];
    AppUser.current = appUsers.firstWhere((e) => e.id == user.uid);
    if (AppUser.current == null) return result;

    List<Group> groups = _rawGroupsData?.docs.map((doc) => Group.fromJson(doc.data())).toList() ?? [];

    for (Group g in groups) {
      if (!AppUser.current!.groupIds.contains(g.id)) continue;
      for (AppUser a in appUsers) {
        if (!a.groupIds.contains(g.id)) continue;
        result.add(a);
      }
    }
    return result;
  }

  Future<bool> createGroup(String name) async {
    AppUser? currentUser = AppUser.current;
    if (currentUser == null) return false;
    final Group group = Group(name: name, autoJoin: true);
    try {
      await _groupCollection.doc(group.id).set(group.toJson(), SetOptions(merge: true));
      await _userCollection.doc(currentUser.id).set({
        "groupIds": FieldValue.arrayUnion(List<String>.from([group.id])),
      }, SetOptions(merge: true));
      Provider.of<DataProvider>(Global.context, listen: false).addGroup(group);
      Log.hint("Created Group \"${group.name}\" (ID: ${group.id}) and saved to cloud.");
      return true;
    } catch (e) {
      Log.error(e);
      return false;
    }
  }

  Future<bool> deleteUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      await _userCollection.doc(user.uid).delete();
      Log.hint("Deleted User (ID: ${user.uid}) from cloud.");
      return true;
    } catch (e) {
      Log.error(e);
      return false;
    }
  }

  Future<void> removeGroup(Group group) async {
    await _groupCollection.doc(group.id).delete();
    Provider.of<DataProvider>(Global.context, listen: false).removeGroup(group);
    Log.hint("Removed Group \"${group.name}\" (ID: ${group.id}) from cloud.");
  }

  Future<bool> joinGroup(String groupId) async {
    // TODO: reload data to ensure that all groups are loaded
    // TODO: check if group exists
    AppUser? currentUser = AppUser.current;
    if (currentUser == null) return false;
    if (currentUser.groupIds.contains(groupId)) {
      Log.error("JOIN GROUP: Already in group (ID: $groupId).");
      return false;
    }
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    await _userCollection.doc(user.uid).set({
      "groupIds": FieldValue.arrayUnion(List<String>.from([groupId])),
    }, SetOptions(merge: true));
    await _groupCollection.doc(groupId).set({
      "users": FieldValue.arrayUnion(List<String>.from([user.uid])),
    }, SetOptions(merge: true));

    // FirebaseMessaging.instance.subscribeToTopic(id);
    await Provider.of<DataProvider>(Global.context, listen: false).reloadData();
    Log.hint("User \"${currentUser.name}\" (User ID: ${currentUser.id}) joined a group (ID: $groupId). Cloud data got saved and reloaded.");
    return true;
  }

  Future<void> createCategory({required String name, required Group group}) async {
    final Category category = Category(groupId: group.id, name: name);
    await _groupCollection.doc(group.id).set({
      "categories": FieldValue.arrayUnion(List<Map<String, dynamic>>.from([category.toJson()])),
    }, SetOptions(merge: true));
    Provider.of<DataProvider>(Global.context, listen: false).addCategory(category: category, group: group);
    Log.hint("Created Category \"${category.name}\" (ID: ${category.id}) and saved to cloud.");
  }

  Future<void> removeCategory(Category category) async {
    await _groupCollection.doc(category.groupId).set({
      "categories": FieldValue.arrayRemove(List<Map<String, dynamic>>.from([category.toJson()])),
    }, SetOptions(merge: true));
    Provider.of<DataProvider>(Global.context, listen: false).removeCategory(category);
    Log.hint("Removed Category \"${category.name}\" (ID: ${category.id}) from cloud.");
  }

  Future<void> addItem({required Category category, required Item item}) async {
    Provider.of<DataProvider>(Global.context, listen: false).addItem(category: category, item: item);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Added Item \"${item.name}\" (ID: ${item.id}) to cloud.");
  }

  Future<void> editItem({required Category category, required Item item, String? name, String? imageUrl}) async {
    Provider.of<DataProvider>(Global.context, listen: false).editItem(category: category, item: item, name: name, imageUrl: imageUrl);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Edited Item \"${item.name}\" (ID: ${item.id}) and saved changes to cloud.");
  }

  Future<void> removeItem({required Category category, required Item item}) async {
    Provider.of<DataProvider>(Global.context, listen: false).removeItem(category: category, item: item);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Removed Item \"${item.name}\" (ID: ${item.id}) from cloud.");
  }

  Future<void> addRating({required Category category, required Rating rating}) async {
    Provider.of<DataProvider>(Global.context, listen: false).addRating(category: category, rating: rating);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(group.id).set({
      // TODO: Refactor to save money (only update the item that was changed) => but is it necessary?
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Added Rating (ID: ${rating.id}) to an item (Item ID: ${rating.itemId}) to cloud.");
  }

  Future<void> editRating({required Category category, required Rating rating, required double value, String? comment}) async {
    Provider.of<DataProvider>(Global.context, listen: false).editRating(category: category, rating: rating, value: value, comment: comment);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(group.id).set({
      // TODO: Refactor to save money (only update the item that was changed) => but is it necessary?
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Edited Rating (ID: ${rating.id}) of item (Item ID: ${rating.itemId}) and save changes to cloud.");
  }

  Future<void> removeRating({required Category category, required Rating rating}) async {
    Provider.of<DataProvider>(Global.context, listen: false).removeRating(category: category, rating: rating);
    Group group = Provider.of<DataProvider>(Global.context, listen: false).userGroups.firstWhere((e) => e.id == category.groupId);
    await _groupCollection.doc(category.groupId).set({
      // TODO: Refactor to save money (only update the item that was changed) => but is it necessary?
      "categories": group.toJson()["categories"],
    }, SetOptions(merge: true));
    Log.hint("Removed Rating (ID: ${rating.id}) from an item (Item ID: ${rating.itemId}) from cloud.");
  }
}
