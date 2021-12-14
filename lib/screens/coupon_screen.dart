import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_vendor/screens/add_edit_coupon_screen.dart';
import 'package:grocery_vendor/services/firebase_services.dart';
import 'package:intl/intl.dart';

class CouponScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Scaffold(
      body: Container(
        child: StreamBuilder(
          stream: _services.coupons
              .where('sellerId', isEqualTo: _services.user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (!snapshot.hasData) {
              return Center(child: Text('No Coupons added yet'));
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        child: Text(
                          'Add New Coupon',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AddEditCoupon.id);
                        },
                      ),
                    ),
                  ],
                ),
                FittedBox(
                  child: DataTable(columns: <DataColumn>[
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Rate')),
                    DataColumn(label: Text('status')),
                    DataColumn(label: Text('Expiry')),
                    DataColumn(label: Text('Info')),
                  ], rows: _couponList(snapshot.data!, context)),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  List<DataRow> _couponList(QuerySnapshot snapshot, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      if (document != null) {
        var date = document.data()['Expiry'];
        var expiry = DateFormat.yMMMd().add_jm().format(date.toDate());
        return DataRow(cells: [
          DataCell(Text(document.data()['title'])),
          DataCell(Text(document.data()['discountRate'].toString())),
          DataCell(Text(document.data()['active'] ? 'active' : 'Inactive')),
          DataCell(Text(expiry.toString())),
          DataCell(IconButton(
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEditCoupon(document: document)));
              })),
        ]);
      }
    }).toList() as List<DataRow>;
    return newList;
  }
}
