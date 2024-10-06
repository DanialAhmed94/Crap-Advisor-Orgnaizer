class InvoiceResponse {
  int status;
  List<Invoice> data;
  String message;

  InvoiceResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      status: json['status'],
      data: List<Invoice>.from(json['data'].map((x) => Invoice.fromJson(x))),
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': List<dynamic>.from(data.map((x) => x.toJson())),
      'message': message,
    };
  }
}

class Invoice {
  int id;
  int eventId;
  int userId;
  String invoicNumber;
  String? strongBilledTo;
  String? festivalName;
  String? eventName;
  String date;
  String crowdCapacity;
  String pricePerPerson;
  String taxPercentage;
  String grandTotal;
  dynamic image;
  String createdAt;
  String updatedAt;

  Invoice({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.invoicNumber,
    this.strongBilledTo,
    this.festivalName,
    this.eventName,
    required this.date,
    required this.crowdCapacity,
    required this.pricePerPerson,
    required this.taxPercentage,
    required this.grandTotal,
    this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      eventId: json['event_id'],
      userId: json['user_id'],
      invoicNumber: json['invoic_number'],
      strongBilledTo: json['strong_billed_to'],
      festivalName: json['festival_name'],
      eventName: json['event_name'],
      date: json['date'],
      crowdCapacity: json['crowd_capacity'],
      pricePerPerson: json['price_per_person'],
      taxPercentage: json['tax_percentage'],
      grandTotal: json['grand_total'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'invoic_number': invoicNumber,
      'strong_billed_to': strongBilledTo,
      'festival_name': festivalName,
      'event_name': eventName,
      'date': date,
      'crowd_capacity': crowdCapacity,
      'price_per_person': pricePerPerson,
      'tax_percentage': taxPercentage,
      'grand_total': grandTotal,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// class InvoiceResponse {
//   int status;
//   List<Invoice> data;
//   String message;
//
//   InvoiceResponse({
//     required this.status,
//     required this.data,
//     required this.message,
//   });
//
//   factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
//     return InvoiceResponse(
//       status: json['status'],
//       data: List<Invoice>.from(json['data'].map((item) => Invoice.fromJson(item))),
//       message: json['message'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'data': data.map((item) => item.toJson()).toList(),
//       'message': message,
//     };
//   }
// }
//
// class Invoice {
//   int? id;
//   int? eventId;
//   int? userId;
//   String? invoicNumber;
//   String? strongBilledTo;
//   String? date;
//   String? crowdCapacity;
//   String? pricePerPerson;
//   String? taxPercentage;
//   String? grandTotal;
//   String? image;
//   String? createdAt;
//   String? updatedAt;
//
//   Invoice({
//      this.id,
//      this.eventId,
//      this.userId,
//      this.invoicNumber,
//     this.strongBilledTo,
//      this.date,
//      this.crowdCapacity,
//      this.pricePerPerson,
//      this.taxPercentage,
//      this.grandTotal,
//     this.image,
//      this.createdAt,
//      this.updatedAt,
//   });
//
//   factory Invoice.fromJson(Map<String, dynamic> json) {
//     return Invoice(
//       id: json['id'],
//       eventId: json['event_id'],
//       userId: json['user_id'],
//       invoicNumber: json['invoic_number'],
//       strongBilledTo: json['strong_billed_to'],
//       date: json['date'],
//       crowdCapacity: json['crowd_capacity'],
//       pricePerPerson: json['price_per_person'],
//       taxPercentage: json['tax_percentage'],
//       grandTotal: json['grand_total'],
//       image: json['image'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'event_id': eventId,
//       'user_id': userId,
//       'invoic_number': invoicNumber,
//       'strong_billed_to': strongBilledTo,
//       'date': date,
//       'crowd_capacity': crowdCapacity,
//       'price_per_person': pricePerPerson,
//       'tax_percentage': taxPercentage,
//       'grand_total': grandTotal,
//       'image': image,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }
