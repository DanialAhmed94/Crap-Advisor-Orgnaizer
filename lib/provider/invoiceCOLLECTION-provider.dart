import 'package:flutter/material.dart';
import '../api/getInvoiceCollection_api.dart';
import '../data_model/invoiceCollection_model.dart';

class InvoiceProvider extends ChangeNotifier {
  List<Invoice> _invoices = [];

  List<Invoice> get invoices => _invoices;

  Future<void> fetchInvoices(BuildContext context) async {
    final response = await getInvoiceCollection(context);  // This function should call the API

    if (response != null) {
      _invoices = response.data;
      notifyListeners();
    }
  }




}
