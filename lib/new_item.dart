
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http ;
import 'package:shopping_list/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget{

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {

 final formkey=GlobalKey<FormState>();
 var enteredname='';
 var enteredcategory=categories[Categories.vegetables]!;
 var enteredquantity='1';
 var isSaving=false;

 void saveitem()async {

    if (formkey.currentState!.validate()) {
  formkey.currentState!.save();
     setState(() {
  isSaving=true;
});
     final url=Uri.https('flutter-prep-5b74d-default-rtdb.firebaseio.com','shopping-list.json');

     final response= await http.post(url,headers: {
        'Content-type':'application/json'
        },
      body: json.encode({
        'name': enteredname, 
        'quantity': enteredquantity, 
        'category': enteredcategory.title
    })
      );
    print(response.body);
    print(response.statusCode);

      if(!context.mounted)
      {
        return;
      }

      final Map<String,dynamic> resData=json.decode(response.body);

    Navigator.of(context).pop(
      GroceryItem(id: resData['name'], name: enteredname, quantity: enteredquantity, category: enteredcategory)

   );
}

 }


@override
  Widget build(BuildContext context) {
 
    return 
          Scaffold(
            appBar: AppBar(title: Text('Add a new Item'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                 key:formkey,
                child: 
              Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: InputDecoration(
                      label: Text("Name")
                    ),
                    validator: (value) {
                      if(value==null||value.isEmpty||value.trim().length<=1||value.trim().length>50)
                      return 'Must be between 1-50 chracters';
                    },
                    onSaved: (value)
                    {
                          enteredname=value!;
                    },
                  ),
                   
                   SizedBox(
                    height: 4,
                   ),
                  
                    Row(
                    children: [
                        Expanded(
                          child: TextFormField(
                            maxLength: 50,
                            decoration: InputDecoration(
                              label: Text('Quantity'),
                              
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value){
                              if(value==null||value.isEmpty||int.tryParse(value)!<=0||int.tryParse(value)!>50
                              )
                              return'Must be a real positive number';
                            },
                            initialValue: '1',
                            onSaved: (value){
                              enteredquantity=int.parse(value!).toString();
                            },
                          ),
                        ),
                      
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: enteredcategory,
                      items: [
                      for(final category in categories.entries)
                      DropdownMenuItem(
                        value: category.value,
                        child: Row(
                      children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: category.value.color,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(category.value.title)
                        ],
                      ))
                    
                    ], onChanged: (value){
                          enteredcategory=value!;
                    }
                    ),
                  )
                     
                      ]
                    ),
                    SizedBox(
                      height: 12,
                    )
                    ,Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: (){
                          formkey.currentState!.reset();
                        }, child: Text("Reset")),
                        ElevatedButton(onPressed: isSaving?null:saveitem, child:isSaving?SizedBox(width: 16,height: 16,child: CircularProgressIndicator(),): Text("Add Item"))
                      ],
                    )
                ],
              
                
              )
              
                         ),
            )
          );

  }
}