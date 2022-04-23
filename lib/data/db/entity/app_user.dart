import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppUser {
  late String id;
  late String name;
  late int age;
  late String profilePhotoPath;
  late String bio = "";
  late List<String> interests = [];
  late String city;
  late String gender;
  late String preference;

  AppUser(
      {required this.id,
      required this.name,
      required this.age,
      required this.profilePhotoPath,
      required this.interests,
      required this.city,
      required this.gender,
      required this.preference});

  AppUser.fromSnapshot(DocumentSnapshot snapshot) {
    id = snapshot['id'];
    name = snapshot['name'];
    age = snapshot['age'];
    profilePhotoPath = snapshot['profile_photo_path'];
    bio = snapshot.get('bio') ?? '';
    interests = snapshot['interests'].cast<String>();
    city = snapshot['city'];
    gender = snapshot['gender'];
    preference = snapshot['preference'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
      'profile_photo_path': profilePhotoPath,
      'bio': bio,
      'interests': interests,
      'city': city,
      'gender': gender,
      'preference': preference,
    };
  }
}
