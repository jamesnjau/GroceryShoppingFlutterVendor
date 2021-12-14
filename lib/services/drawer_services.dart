import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor/screens/banner_screen.dart';
import 'package:grocery_vendor/screens/coupon_screen.dart';
import 'package:grocery_vendor/screens/dashboard_screen.dart';
import 'package:grocery_vendor/screens/login_screen.dart';
import 'package:grocery_vendor/screens/order_screen.dart';
import 'package:grocery_vendor/screens/product_screen.dart';
import 'package:grocery_vendor/screens/spash_screen.dart';

class DrawerServices {
  Widget drawerScreen(title) {
    if (title == 'Dashboard') {
      return MainScreen();
    }
    if (title == 'Product') {
      return ProductcScreen();
    }
    if (title == 'Banner') {
      return BannerScreen();
    }
    if (title == 'Coupons') {
      return CouponScreen();
    }
    if (title == 'Orders') {
      return OrderScreen();
    }
    if (title == 'LogOut') {
      FirebaseAuth.instance.signOut();
      return LoginScreen();
    }
    return MainScreen();
  }
}
