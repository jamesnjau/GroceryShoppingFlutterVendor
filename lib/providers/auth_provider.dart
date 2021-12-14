import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class AuthProvider extends ChangeNotifier {
  late File image;
  String pickerError = '';
  bool isPicAvail = false;
  late String error = '';

  //shop data
  late double shopLatitude;
  late double shopLongitude;
  late String shopAddress;
  late String placeName;
  late String email;

  Future<File> getImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 20);
    if (pickedFile != null) {
      this.image = File(pickedFile.path);
      notifyListeners();
    } else {
      this.pickerError = 'no image selected';
      print('No image selected');
      notifyListeners();
    }
    return this.image;
  }

  Future getCurrentAddress() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    this.shopLatitude = _locationData.latitude;
    this.shopLongitude = _locationData.longitude;
    notifyListeners();

    final coordinates =
        new Coordinates(_locationData.latitude, _locationData.longitude);
    var _addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var shopAddress = _addresses.first;
    this.shopAddress = shopAddress.addressLine;
    this.placeName = shopAddress.featureName;
    notifyListeners();
    return shopAddress;
  }

//Register vendor using email and password
  Future<UserCredential> registerVendor(email, password) async {
    this.email = email;
    notifyListeners();
    late UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        this.error = 'The password provided is too weak';
        notifyListeners();
        print('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        this.error = 'Email already in use';
        notifyListeners();
        print('Email already in use');
      }
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e.toString());
    }
    return userCredential;
  }

//Register vendor using email and password
  Future<UserCredential> loginVendor(email, password) async {
    this.email = email;
    notifyListeners();
    late UserCredential userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
      print(e.toString());
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e.toString());
    }
    return userCredential;
  }

//reset password
  Future<void> resetPassword(email) async {
    this.email = email;
    notifyListeners();
    late UserCredential userCredential;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      this.error = e.code;
      notifyListeners();
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
    return null;
  }

  Future<void>? saveVendorDataToDb(
      {required String url,
      required String shopName,
      required String mobile,
      required String dialog}) {
    User user = FirebaseAuth.instance.currentUser;
    DocumentReference _vendors =
        FirebaseFirestore.instance.collection('vendors').doc(user.uid);
    _vendors.set({
      'uid': user.uid,
      'shopName': shopName,
      'mobile': mobile,
      'email': this.email,
      'dialog': dialog,
      'address': '${this.placeName}:${this.shopAddress}',
      'location': GeoPoint(this.shopLatitude, this.shopLongitude),
      'shopOpen': true,
      'rating': 0.00,
      'totalRating': 0,
      'isTopPicked': false, // keep original value as false
      'imageUrl': url,
      'accVerified': false, // keep original value as false
    });

    return null;
  }
}
