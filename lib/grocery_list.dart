import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:shopping_list/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/new_item.dart';
import 'package:http/http.dart'as http;

class GroceryList extends StatefulWidget{
 GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
var  groceryItems=[];
var isLoading=true;
String?error;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaditem();
  }


void loaditem()async {
       final url=Uri.https('flutter-prep-5b74d-default-rtdb.firebaseio.com','shopping-list.json');
          final response =await http.get(url);
          if(response.statusCode>400)
          {
            setState(() {
                error='Failed to fetch data.Please try again later.';
                   });
          }
          final List<GroceryItem>loadeditems=[];
            final Map<String,dynamic> listdata=json.decode(response.body);     

                    for(final item in listdata.entries){
                                final category=categories.entries.firstWhere((element) => element.value.title==item.value['category']).value;

                          loadeditems.add(GroceryItem(id: item.key, name: item.value['name'], quantity: item.value['quantity'], category: category));
                    }
      setState(() {
  groceryItems=loadeditems;
  isLoading=false;
});
}

 void addItem()async{

        final newItem=await Navigator.of(context).push<GroceryItem>(
          MaterialPageRoute(builder:(ctx)=> NewItem())
          
          );
          if(newItem==null)
          {
            return;
          }

                setState(() {
         groceryItems.add(newItem);

                               });

          
              }

void removeitem(GroceryItem item)async{
     final index=groceryItems.indexOf(item);
    setState(() {
  groceryItems.remove(item);
});

     final url= Uri.https('flutter-prep-5b74d-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
          final response=await http.delete(url);
          
          if(response.statusCode>400)
          {
            setState(() {
              groceryItems.insert(index, item);
            });
          }
          
}
     
    

@override
  Widget build(BuildContext context) {
    
       Widget maincontent=Center(child: Text("Your list looks empty!",style: TextStyle(color: Colors.white),));

          if(isLoading)
          {
            maincontent=Center(child: CircularProgressIndicator(),);
          }

    if(groceryItems.isNotEmpty)
    {
      maincontent= ListView.builder(
          itemCount: groceryItems.length,
          itemBuilder: 
        (ctx,index)=>
           
          Dismissible(
            key: ValueKey(                  //this should contain a unique identification key for the value
              groceryItems[index].id

            ),
            onDismissed: (direction) {
              removeitem(groceryItems[index]);
            },
            background: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded),
                    Center(child: Text('Delete')),
                  ],
                ),
            color: Theme.of(context).colorScheme.error,
            ),
            child: ListTile(
              title: Text(groceryItems[index].name),
              leading: Container(
                width: 24,height: 24,
                color: groceryItems[index].category.color,
                
              ),
              trailing: Text(groceryItems[index].quantity.toString()),
            ),
          )

        
        );
    }
    
    if(error!=null)
    {
      maincontent=Center(child: Text(error!),);
    }

  return
    Scaffold(
      appBar: AppBar(title: 
      Text('Your Groceries')
      ,
      actions: [
        IconButton(onPressed: addItem, icon: Icon(Icons.add))
      ],
      ),
    body: maincontent
         
           
    );
     
     
  }
}