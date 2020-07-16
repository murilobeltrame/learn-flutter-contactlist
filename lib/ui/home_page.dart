import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {
  ORDER_AZ,
  ORDER_ZA
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> _contacts = List();

  Widget _createContactCard(BuildContext context, int index) {

    final Contact contact = _contacts[index];

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
                    image: contact.image != null ? FileImage(File(contact.image)) : AssetImage('images/person.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contact.name ?? '',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact.email ?? '',
                      style: TextStyle(fontSize: 18.0,),
                    ),
                    Text(
                      contact.phone ?? '',
                      style: TextStyle(fontSize: 18.0,),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showContactOptions(context, index);
      },
    );
  }

  void _showContactOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Ligar',
                          style: TextStyle(
                              color:Colors.red,
                              fontSize: 20.0),
                        ),
                        onPressed: (){
                          launch('tel:${_contacts[index].phone}');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Editar',
                          style: TextStyle(
                              color:Colors.red,
                              fontSize: 20.0),
                        ),
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact: _contacts[index]);
                        },
                      ),
                    ),Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text(
                          'Excluir',
                          style: TextStyle(
                              color:Colors.red,
                              fontSize: 20.0),
                        ),
                        onPressed: (){
                          helper.deleteContact(_contacts[index].id);
                          setState(() {
                            _contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            onClosing: (){},
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final contactRecord = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,)),
    );
    if (contactRecord != null) {
      if (contact != null) await helper.updateContact(contactRecord);
      else await helper.saveContact(contactRecord);
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        _contacts = list;
      });
    });
  }

  void _sortContactList(OrderOptions orderOption) {
    switch(orderOption) {
      case OrderOptions.ORDER_AZ:
        _contacts.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case OrderOptions.ORDER_ZA:
        _contacts.sort((a,b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }
    setState(() { });
  }

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A-Z"),
                value: OrderOptions.ORDER_AZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.ORDER_ZA,
              ),
            ],
            onSelected: _sortContactList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: _contacts.length,
        itemBuilder: _createContactCard),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        onPressed: _showContactPage,
      ),
    );
  }
}
