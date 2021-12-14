import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_vendor/services/firebase_services.dart';

class BannerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();

    return StreamBuilder<QuerySnapshot>(
        stream: _services.vendorbanner.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading...');
          }
          return Container(
            height: 180,
            width: MediaQuery.of(context).size.width,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: Image.network(
                            document['imageUrl'],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                          right: 10,
                          top: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () {
                                EasyLoading.show(status: 'Deleting...');
                                _services.deleteBanner(id: document.id);
                                EasyLoading.dismiss();
                              },
                            ),
                          ))
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        });
  }
}
