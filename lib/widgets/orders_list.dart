import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../consts/constants.dart';
import 'orders_widget.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({Key? key, this.isInDashboard = true}) : super(key: key);
  final bool isInDashboard;

  
  @override
  Widget build(BuildContext context) {
    String idCommande = '';
    String idClient = '';
    Timestamp dateCommande = Timestamp(1, 1);
    double prixTotal = 0.0;
    FirebaseFirestore.instance
        .collection('Commandes')
        .get()
        .then((QuerySnapshot commandeSnapshot) {
      commandeSnapshot.docs.forEach((element) {
        idClient = element.get('idClient');
        idCommande = element.get('idCommande');
        dateCommande = element.get('dateCommande');
        prixTotal = element.get('prixTotal');
      });
    });
    return StreamBuilder<QuerySnapshot>(
      //there was a null error just add those lines
      stream: FirebaseFirestore.instance.collection('ligneCommandes').snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data!.docs.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: isInDashboard && snapshot.data!.docs.length > 4
                      ? 4
                      : snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return Column(
                      children: [
                        OrdersWidget(
                          price: snapshot.data!.docs[index]['prix'],
                          totalPrice: prixTotal,
                          productId: snapshot.data!.docs[index]['idProduit'],
                          userId: idClient,
                          quantity: snapshot.data!.docs[index]['quantite'],
                          orderDate: dateCommande,
                          imageUrl: snapshot.data!.docs[index]['imageUrl'],
                        ),
                        const Divider(
                          thickness: 3,
                        ),
                      ],
                    );
                  }),
            );
          } else {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(18.0),
                child: Text('Your store is empty'),
              ),
            );
          }
        }
        return const Center(
          child: Text(
            'Something went wrong',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
        );
      },
    );
  }
}
