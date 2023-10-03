import 'dart:convert';
import 'dart:io';
import 'package:crud_api/insert_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
class RestaurantForm extends StatefulWidget {
  @override
  _RestaurantFormState createState() => _RestaurantFormState();
}

class _RestaurantFormState extends State<RestaurantForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController deliveryFeeController = TextEditingController();
  TextEditingController deliveryTimeController = TextEditingController();

  File? images;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        images = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void submitForm() async{
    if (_formKey.currentState!.validate()) {
      // Retrieve the form field values from the controllers
      String name = nameController.text;
      String category = categoryController.text;
      int discount = int.parse(discountController.text);
      double deliveryFee = double.parse(deliveryFeeController.text);
      int deliveryTime = int.parse(deliveryTimeController.text);

      // You can perform further actions with the form data and the selected image here
      //posting Image
      var id;
      var request = http.MultipartRequest('POST', Uri.parse('https://cms.istad.co/api/upload'));
      // Add the image file to the request
      if (images != null) {
        request.files.add(await http.MultipartFile.fromPath('files', images!.path));
      }
      // Send the request and handle the response
      var response = await request.send();
      if (response.statusCode == 200) {
        print('API request successful');
        var responseBody = await response.stream.bytesToString();
        var parsedResponse = jsonDecode(responseBody);
        id = parsedResponse[0]['id'];
        print('The ID is: $id');
        print(responseBody);
      } else {
        print('API request failed');
      }
      //positing restaurant
      RestaurantInsertModel restaurantData = RestaurantInsertModel(
        data: Data(
          name: name,
          category: category,
          discount: discount,
          deliveryFee: deliveryFee,
          deliveryTime: deliveryTime,
          picture: "${id}",
        ),
      );
      String jsonData = restaurantInsertModelToJson(restaurantData);
      print(jsonData);
      var headers = {
        'Content-Type': 'application/json'
      };
      var requests = http.Request('POST', Uri.parse('https://cms.istad.co/api/food-panda-restaurants'));
      requests.body =jsonData;
      requests.headers.addAll(headers);
      http.StreamedResponse responses = await requests.send();

      if (responses.statusCode == 200) {
        print(await responses.stream.bytesToString());
      }
      else {
        print(responses.reasonPhrase);
      }

      // Reset the form
      _formKey.currentState!.reset();

      // Clear the text field controllers
      nameController.clear();
      categoryController.clear();
      discountController.clear();
      deliveryFeeController.clear();
      deliveryTimeController.clear();
      // Clear the image selection
      setState(() {
        images = null;
      });
    }
  }

  @override
  void dispose() {
    // Dispose the text field controllers when the widget is disposed
    nameController.dispose();
    categoryController.dispose();
    discountController.dispose();
    deliveryFeeController.dispose();
    deliveryTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
                controller: categoryController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Discount',
                ),
                controller: discountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a discount';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Delivery Fee',
                ),
                controller: deliveryFeeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a delivery fee';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Delivery Time',
                ),
                controller: deliveryTimeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a delivery time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 16.0),
              images != null
                  ? Image.file(images!)
                  : const Icon(Icons.image, size: 100),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
