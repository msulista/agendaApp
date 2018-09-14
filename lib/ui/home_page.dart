import 'dart:async';
import 'dart:io';

import 'package:agenda_contato/helpers/contact_helper.dart';
import 'package:agenda_contato/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderAz, orderZa}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();



  @override
  void initState() {
    super.initState();

    _getAllContacts();

//    helper.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de A-Z"),
                  value: OrderOptions.orderAz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderZa,
              ),
            ],
            onSelected: _orderList,

          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (content, index) {

            //CORPO DO APP

            return _contactCard(context, index);

          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null ?
                        FileImage(File(contacts[index].img)) :
                        AssetImage("images/person.png")
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(contacts[index].nome ?? "Novo Contato",
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                        Text(contacts[index].email ?? "",
                          style: TextStyle(
                              fontSize: 18.0,
                          ),
                        ),
                        Text(contacts[index].phone ?? "",
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                        child: Text("Ligar",
                                    style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      onPressed: () {
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Editar",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                    FlatButton(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Excluir",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
    );
  }

  Future _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context)=>CantactPage(contact: contact))
    );

    if(recContact != null) {
      if(contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }


  void _getAllContacts() {
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderAz:
        contacts.sort((a, b) {
          return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
        });
        break;
      case OrderOptions.orderZa:
        contacts.sort((a, b) {
          return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
