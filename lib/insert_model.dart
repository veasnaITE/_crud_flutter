
import 'dart:convert';

RestaurantInsertModel restaurantInsertModelFromJson(String str) => RestaurantInsertModel.fromJson(json.decode(str));

String restaurantInsertModelToJson(RestaurantInsertModel data) => json.encode(data.toJson());

class RestaurantInsertModel {
  Data? data;

  RestaurantInsertModel({
    this.data,
  });

  factory RestaurantInsertModel.fromJson(Map<String, dynamic> json) => RestaurantInsertModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
  };
}

class Data {
  String? name;
  String? category;
  int? discount;
  double? deliveryFee;
  int? deliveryTime;
  String? picture;

  Data({
    this.name,
    this.category,
    this.discount,
    this.deliveryFee,
    this.deliveryTime,
    this.picture,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    name: json["name"],
    category: json["category"],
    discount: json["discount"],
    deliveryFee: json["deliveryFee"]?.toDouble(),
    deliveryTime: json["deliveryTime"],
    picture: json["picture"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "category": category,
    "discount": discount,
    "deliveryFee": deliveryFee,
    "deliveryTime": deliveryTime,
    "picture": picture,
  };
}
