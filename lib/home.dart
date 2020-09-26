import 'dart:math';
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
 
  final _amountController = TextEditingController();
  String _amount = '';

  Future<List<ApplicationMeta>> _appsFuture;

  @override
  void initState() {
    super.initState();

    _appsFuture = UpiPay.getInstalledUpiApplications();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    
    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    if (_amount != _amountController.text) {
      int amnt = int.parse(_amountController.text);
      double doubleAmnt = amnt.toDouble();
      _amountController.text = doubleAmnt.toStringAsFixed(2);
      _amount = doubleAmnt.toStringAsFixed(2);
    }

    //print(doubleAmnt.toStringAsFixed(2));

    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'Receiver Name',
      receiverUpiAddress: 'abilash89938@okhdfcbank',
      transactionRef: transactionRef,
      //merchantCode: '7372',
    );

    print(a);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'UPI Payment',
            style: GoogleFonts.roboto(),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    Text(
                      'Contribute Us',
                      style: GoogleFonts.roboto(
                          fontSize: 15),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _amountController,
                      style: GoogleFonts.roboto(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 128, bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Pay Using',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    FutureBuilder<List<ApplicationMeta>>(
                      future: _appsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Container();
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.6,
                          physics: NeverScrollableScrollPhysics(),
                          children: snapshot.data
                              .map((it) => Material(
                                    key: ObjectKey(it.upiApplication),
                                    color: Colors.grey[200],
                                    child: InkWell(
                                      onTap: () => _onTap(it),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Image.memory(
                                            it.icon,
                                            width: 64,
                                            height: 64,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            child: Text(
                                              it.upiApplication.getAppName(),
                                              style: GoogleFonts.roboto(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
  }
}

