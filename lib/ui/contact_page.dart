import 'dart:async';
import 'dart:io';

import 'package:agenda_contato/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter/services.dart';

class CantactPage extends StatefulWidget {

  final Contact contact;

  CantactPage({this.contact});

  @override
  _CantactPageState createState() => _CantactPageState();
}

class _CantactPageState extends State<CantactPage> {

  final String _emailRegExp =  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();
//  final _foneController = new TextEditingController();
  final _foneController = new MaskedTextController(mask: '(00) 0000-0000*');

  final _nomeFocus = new FocusNode();
  final _foneFocus = new FocusNode();

  bool _userEdited = false;

  Contact _editedContact;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if(widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.nome;
      _emailController.text = _editedContact.email;
      _foneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.nome ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {

            if(_formKey.currentState.validate()) {
              Navigator.pop(context, _editedContact);
            }

            setState(() {
              _editedContact.nome = _nameController.text;
              _editedContact.email = _emailController.text;
              _editedContact.phone = _foneController.text;
            });

          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          //CORPO DO APP
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact.img != null
                              ? FileImage(File(_editedContact.img))
                              : AssetImage("images/person.png")),
                    ),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera)
                        .then((file) {
                      if (file == null) return;
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nomeFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  validator: (value) {
                    _userEdited = true;
                    if (value.isEmpty) {
                      return "Insira um nome!";
                    } else {
                      setState(() {
                        _editedContact.nome = value;
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "E-mail"),
//                    inputFormatters: [WhitelistingTextInputFormatter(RegExp("[a-zA-Z]"))],
                  validator: (value) {
                    _userEdited = true;
                    if (value.isNotEmpty) {
                      if (isEmail(value)) {
                        setState(() {
                          _editedContact.email = value;
                        });
                      } else {
                        return "Insira um e-mail válido!";
                      }
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _foneController,
                  focusNode: _foneFocus,
                  decoration: InputDecoration(labelText: "Fone"),
                  validator: (value) {
                    _userEdited = true;
                    if (value.isNotEmpty) {
                      setState(() {
                        _editedContact.phone = value;
                      });
                    } else {
                      return "Insira um telefone!";
                    }
                  },
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<bool> _requestPop() {

    if(_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                 child: Text("Cancelar"),
                  onPressed: () {
                   Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Descartar"),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }


  bool isEmail(String email) {
    RegExp regex = new RegExp(_emailRegExp);
    return regex.hasMatch(email);
  }
}






