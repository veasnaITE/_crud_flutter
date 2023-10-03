import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:crud_api/get_restaurant_model.dart';
import 'package:crud_api/views/insertdata.dart';
import 'package:crud_api/views/update_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<RestaurantModel> futureRestaurant;
  Future<RestaurantModel> fetchRestaurantData() async {
    final response = await http.get(Uri.parse(
        'https://cms.istad.co/api/food-panda-restaurants?populate=*'));
    if (response.statusCode == 200) {
      return restaurantModelFromJson(response.body);
    } else {
      // Handle the error case
      throw Exception('Failed to fetch restaurant data');
    }
  }

  Future<dynamic> deleteRestaurant(int id) async {
    final response = await http.delete(
      Uri.parse('https://cms.istad.co/api/food-panda-restaurants/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  @override
  void initState() {
    super.initState();
    futureRestaurant = fetchRestaurantData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<RestaurantModel>(
      future: futureRestaurant,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final item = snapshot.data!.data![index].attributes;
              final idpass =snapshot.data!.data![index].id?.toInt();
              return Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        child: Image.network(
                          'https://cms.istad.co${item?.picture?.data?.attributes?.url}',
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text("${item?.name}"),
                           Text("${item?.category}"),
                           Text("${item?.createdAt}"),
                        ],
                      ),
                      Expanded(
                        child: IconButton(
                            onPressed:() {Navigator.push(context,
                                MaterialPageRoute(builder: (context) => RestaurantForm()));},
                            icon: const Icon(Icons.add)),
                      ),
                      Expanded(
                        child: IconButton(
                            onPressed:() async {
                              if (await confirm(context)) {
                                return deleteRestaurant(idpass!);
                              }
                            },
                            icon: const Icon(Icons.close)),
                      ),
                      Expanded(
                        child: IconButton(
                            onPressed:() {Navigator.push(context,
                                MaterialPageRoute(builder: (context) => UpdateRestaurantForm(idpass!)));},
                            icon: const Icon(Icons.edit)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: Text('No data available.'),
        );
      },
    ));
  }
}
