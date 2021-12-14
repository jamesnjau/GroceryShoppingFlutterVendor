import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductProvider with ChangeNotifier {
  late String selectedCategory;
  late String selectedSubCategory;
  late String categoryImage;
  late File image;
  late String pickerError;
  late String shopName;
  late String productUrl;

  selectCategory(mainCategory, categoryImage) {
    this.selectedCategory = mainCategory;
    this.categoryImage = categoryImage;
    notifyListeners();
  }

  selectSubCategory(selected) {
    this.selectedSubCategory = selected;
    notifyListeners();
  }

  getShopName(shopName) {
    this.shopName = shopName;
    notifyListeners();
  }

  resetProvider() {
    //remove all existing data
    this.selectedCategory = '';
    this.selectedSubCategory = '';
    this.categoryImage = '';
    // this.image = null;
    this.productUrl = '';
    notifyListeners();
  }

  //upload product image
  Future<String> uploadProductImage(filePath, productName) async {
    File file = File(filePath); // file path to upload
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;
    try {
      await _storage
          .ref('productImage/${this.shopName}/$productName$timeStamp')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    //now after upload file we need to file url path tot save in database
    String downloadURL = await _storage
        .ref('productImage/${this.shopName}/$productName$timeStamp')
        .getDownloadURL();

    this.productUrl = downloadURL;
    notifyListeners();
    return downloadURL;
  }

  Future<File> getProductImage() async {
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

  alertDialog({context, title, content}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  //save product data to firebase
  Future<void> saveProductDataToDb({
    productName,
    description,
    price,
    comparedPrice,
    collection,
    brand,
    sku,
    weight,
    tax,
    stockQty,
    lowStockQty,
    context,
  }) async {
    var timeStamp = DateTime.now().microsecondsSinceEpoch; // use as product id
    User user = FirebaseAuth.instance.currentUser;
    CollectionReference _product =
        FirebaseFirestore.instance.collection('products');
    try {
      _product.doc(timeStamp.toString()).set({
        'seller': {'shopName': this.shopName, 'sellerUid': user.uid},
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': this.selectedCategory,
          'subCategory': this.selectedSubCategory,
          'categoryImage': this.categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'published': false, //keep initial value as false
        'productId': timeStamp.toString(),
        'productImage': this.productUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVE DATA',
          content: 'Product Details saved successfully');
    } catch (e) {
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
    return null;
  }

  Future<void> updateProduct({
    productName,
    description,
    price,
    comparedPrice,
    collection,
    brand,
    sku,
    weight,
    tax,
    stockQty,
    lowStockQty,
    context,
    productId,
    image,
    category,
    subCategory,
    categoryImage,
  }) async {
    // var timeStamp = DateTime.now().microsecondsSinceEpoch; // use as product id
    // User user = FirebaseAuth.instance.currentUser;
    CollectionReference _product =
        FirebaseFirestore.instance.collection('products');
    try {
      _product.doc(productId).update({
        'productName': productName,
        'description': description,
        'price': price,
        'comparedPrice': comparedPrice,
        'collection': collection,
        'brand': brand,
        'sku': sku,
        'category': {
          'mainCategory': category,
          'subCategory': subCategory,
          'categoryImage':
              this.categoryImage == null ? categoryImage : this.categoryImage
        },
        'weight': weight,
        'tax': tax,
        'stockQty': stockQty,
        'lowStockQty': lowStockQty,
        'productImage': this.productUrl == null ? image : this.productUrl
      });
      this.alertDialog(
          context: context,
          title: 'SAVE DATA',
          content: 'Product Details saved successfully');
    } catch (e) {
      this.alertDialog(
        context: context,
        title: 'SAVE DATA',
        content: '${e.toString()}',
      );
    }
    return null;
  }
}
