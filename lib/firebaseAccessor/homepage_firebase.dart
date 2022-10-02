import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edunciate/firebaseAccessor/firebase_listener.dart';
import 'package:edunciate/homepage/items/class_item.dart';
import 'package:edunciate/user_info_item.dart';

class HomepageFirebaseAccessor {
  static const String usersCollection = "Users";
  static const String usernameKey = "name";
  static const String classesKey = "classes";

  static const String classesCollection = "Classes";
  static const String nameKey = "name";
  static const String photoKey = "photo";
  static const String codeKey = "code";
  static const String isPrivateKey = "isPrivate";
  static const String membersKey = "members";
  static const String announcementsKey = "announcements";
  static const String descriptionKey = "description";
  static const String discussionsKey = "discussions";
  static const String eventsKey = "events";

  static const String membersCollection = "Members";
  static const String roleKey = "role";
  static const String personIDKey = "personID";
  static const String classKey = "classID";
  static const String conversationLastSeenKey = "conversationLastSeen";

  static const String discussionsCollection = "Discussions";
  static const String discussionNameKey = "name";
  static const String discussionMembersKey = "members";
  static const String messagesKey = "messages";
  static const String mostRecentUpdateKey = "mostRecentUpdate";

  late FirebaseFirestore _storage;

  HomepageFirebaseAccessor() {
    _storage = FirebaseFirestore.instance;
  }

  Future<void> getUserClasses(String userID, FirebaseListener listener) async {
    DocumentSnapshot user =
        await _storage.collection(usersCollection).doc(userID).get();
    List<DocumentReference> userClasses = user.get(classesKey);
    List returnValues = [];
    for (int i = 0; i < userClasses.length; i++) {
      String classID = userClasses.elementAt(i).id;
      DocumentSnapshot classInfo =
          await _storage.collection(classesCollection).doc(classID).get();
      QuerySnapshot memberInfo = (await _storage
          .collection(membersCollection)
          .where(personIDKey, isEqualTo: userID)
          .where(classKey, isEqualTo: classID)
          .get());

      ClassRole role = ClassRole.nonMember;
      if (memberInfo.docs.length != 0) {
        role = ClassRole.getRole(memberInfo.docs.elementAt(0).get(roleKey));
      }

      returnValues.add(ClassItem((classInfo.get(photoKey) as List).cast<int>(),
          classInfo.get(nameKey), role));
    }
    listener.onSuccess(returnValues);
  }

  void isClassPrivate(String classID) {}

  Future<void> joinClass(String userID, String classID, String code,
      UserRole userRole, FirebaseListener listener) async {
    DocumentSnapshot<Map<String, dynamic>> classInfo =
        await _storage.collection(classesCollection).doc(classID).get();
    if (classInfo.get(codeKey) != code) {
      listener.onFailure("Not the right code.");
      return;
    }
    QuerySnapshot<Map<String, dynamic>> potentialMemberInfo = await _storage
        .collection(membersCollection)
        .where(personIDKey, isEqualTo: userID)
        .where(classKey, isEqualTo: classID)
        .get();

    DocumentReference memberID;
    String classRole = (userRole == UserRole.owner)
        ? ClassRole.owner.name
        : ClassRole.member.name;
    if (potentialMemberInfo.docs.isNotEmpty) {
      Map<String, dynamic> oldData =
          potentialMemberInfo.docs.elementAt(0).data();
      oldData[roleKey] = classRole;
      memberID = potentialMemberInfo.docs.elementAt(0).reference;
      _storage.collection(membersCollection).doc(memberID.id).update(oldData);
    } else {
      Map<String, dynamic> newData = Map<String, dynamic>();
      newData.putIfAbsent(personIDKey, () => userID);
      newData.putIfAbsent(classKey, () => classID);
      newData.putIfAbsent(roleKey, () => classRole);
      newData.putIfAbsent(
          conversationLastSeenKey, () => Map<String, Timestamp>());
      memberID = (await _storage.collection(membersCollection).add(newData));
    }
    DocumentSnapshot<Map<String, dynamic>> member =
        await _storage.collection(membersCollection).doc(memberID.id).get();
    Map<String, dynamic> classData = classInfo.data()!;

    List<DocumentReference> listOfCurrentMembers = classData[membersKey];
    for (int i = 0; i < listOfCurrentMembers.length; i++) {
      createDiscussion(memberID, listOfCurrentMembers[i], classID);
    }

    (classData[membersKey] as List)
        .cast<DocumentReference>()
        .add(member.reference);
    await _storage.collection(classesCollection).doc(classID).update(classData);
    listener.onSuccess([member.id]);
  }

  Future<void> createClass(
      String userID, String name, FirebaseListener listener) async {
    Map<String, dynamic> memberData = Map<String, dynamic>();
    memberData.putIfAbsent(personIDKey, () => userID);
    memberData.putIfAbsent(roleKey, () => ClassRole.owner.name);
    memberData.putIfAbsent(
        conversationLastSeenKey, () => Map<String, DocumentReference>());
    DocumentReference memberIncompleteInfo =
        await _storage.collection(membersCollection).add(memberData);

    Map<String, dynamic> newData = Map<String, dynamic>();
    newData.putIfAbsent(photoKey, () => [0]);
    newData.putIfAbsent(nameKey, () => name);
    newData.putIfAbsent(isPrivateKey, () => true);
    newData.putIfAbsent(descriptionKey, () => "");
    newData.putIfAbsent(codeKey, () => _generateRandomCode());
    newData.putIfAbsent(discussionsKey, () => <DocumentReference>[]);
    newData.putIfAbsent(announcementsKey, () => <DocumentReference>[]);
    newData.putIfAbsent(eventsKey, () => <DocumentReference>[]);
    newData.putIfAbsent(
        membersKey, () => <DocumentReference>[memberIncompleteInfo]);
    DocumentReference classInfo =
        await _storage.collection(classesCollection).add(newData);

    memberData.putIfAbsent(classKey, () => classInfo);
    await _storage.collection(membersCollection).add(memberData);

    listener.onSuccess([classInfo.id]);
  }

  String _generateRandomCode() {
    String characterSource =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#\$%^&*()";
    String code = "";
    for (int i = 0; i < 10; i++) {
      int random = Random().nextInt(characterSource.length);
      code += String.fromCharCode(characterSource.codeUnitAt(random));
    }
    return code;
  }

  Future<void> createDiscussion(DocumentReference firstMemberID,
      DocumentReference secondMemberID, String classID) async {
    if ((await _storage
            .collection(discussionsCollection)
            .where(discussionMembersKey, arrayContains: firstMemberID)
            .where(discussionMembersKey, arrayContains: secondMemberID)
            .get())
        .docs
        .isNotEmpty) {
      return;
    }
    DocumentSnapshot<Map<String, dynamic>> firstMemberInfo = await _storage
        .collection(membersCollection)
        .doc(firstMemberID.id)
        .get();
    DocumentSnapshot<Map<String, dynamic>> secondMemberInfo = await _storage
        .collection(membersCollection)
        .doc(secondMemberID.id)
        .get();

    DocumentSnapshot firstUserInfo = await _storage
        .collection(usersCollection)
        .doc(firstMemberInfo.get(personIDKey))
        .get();
    DocumentSnapshot secondUserInfo = await _storage
        .collection(usersCollection)
        .doc(secondMemberInfo.get(personIDKey))
        .get();

    String firstUsername =
        firstUserInfo.get(usernameKey).toString().split(";").first;
    String secondUsername =
        secondUserInfo.get(usernameKey).toString().split(";").first;

    String convoName = firstUsername + " and " + secondUsername;
    Map<String, dynamic> newConvoData = Map<String, dynamic>();
    newConvoData.putIfAbsent(discussionNameKey, () => convoName);
    newConvoData.putIfAbsent(messagesKey, () => <DocumentReference>[]);
    newConvoData.putIfAbsent(discussionMembersKey,
        () => [firstMemberInfo.reference, secondMemberInfo.reference]);
    newConvoData.putIfAbsent(mostRecentUpdateKey, () => Timestamp.now());
    DocumentReference convoRef =
        await _storage.collection(discussionsCollection).add(newConvoData);

    Map<String, Timestamp> firstMembersConvos =
        firstMemberInfo.get(conversationLastSeenKey);
    firstMembersConvos.putIfAbsent(convoRef.id, () => Timestamp.now());
    Map<String, Timestamp> secondMembersConvos =
        secondMemberInfo.get(conversationLastSeenKey);
    secondMembersConvos.putIfAbsent(convoRef.id, () => Timestamp.now());
    _storage
        .collection(membersCollection)
        .doc(firstMemberID.id)
        .update(firstMemberInfo.data()!);
    _storage
        .collection(membersCollection)
        .doc(secondMemberID.id)
        .update(secondMemberInfo.data()!);

    DocumentSnapshot<Map<String, dynamic>> classesInfo =
        await _storage.collection(classesCollection).doc(classID).get();
    List<DocumentReference> discussions = classesInfo.get(discussionsKey);
    discussions.add(convoRef);
    _storage
        .collection(classesCollection)
        .doc(classID)
        .update(classesInfo.data()!);
  }
}