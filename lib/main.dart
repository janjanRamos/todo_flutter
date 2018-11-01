import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'TODO',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: new MyHomePage(title: 'TODO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  var list;

  @override
  _MyHomePageState createState() => new _MyHomePageState();


}

class _MyHomePageState extends State<MyHomePage> {

// A function that will convert a response body into a List<Photo>
  List<Todo> parseTodos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Todo>((json) => Todo.fromJson(json)).toList();
  }

  Future<List<Todo>> fetchTodo() async {
    final response =
    await http.get('https://infinite-river-74609.herokuapp.com/api/todos');

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      return parseTodos(response.body);
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new FutureBuilder<List>(
        future: fetchTodo(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? new TodoList(
            todos: snapshot.data,
          )
              : new Center(
            child: new CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}


class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: new Column(
        children: <Widget>[
          new RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: new Text("back"),
          ),
        ],
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;

  TodoList({Key key, this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return new Container(
            child: ListTile(
              title: new Text(todos[index].summary),
              trailing: new Icon(todos[index].done ? Icons.check_box : Icons
                  .check_box_outline_blank),
              onLongPress: () {
                if (todos[index].done) {
                  MetodosHttp.undone(todos[index].id);
                } else {
                  MetodosHttp.done(todos[index].id);
                  todos[index].done = true;
                }
                Navigator
                    .push(
                  context,
                  new MaterialPageRoute(builder: (context) => new SecondPage()),
                );
              },


              leading: new FlatButton(
                color: Colors.red,
                onPressed: () {
                  MetodosHttp.delete(todos[index].id);
                  Navigator
                      .push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SecondPage()),
                  );
                },
                child: new Text("Delete"),

              ),
            ));
      },
    );
  }
}

class MetodosHttp {


  static final String initialPath =
      "https://infinite-river-74609.herokuapp.com/api/todos";

  static void delete(int id) {
    String url = initialPath + "/delete/" + id.toString();
    http.post(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });
  }

  static void done(int id) {
    String url = initialPath + "/done/" + id.toString();

    http.post(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });
  }

  static void undone(int id) {
    String url = initialPath + "/undone/" + id.toString();
    http.post(url, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });
  }
}

class Todo {
  int id;
  String summary;
  bool done;

  Todo({this.id, this.summary, this.done});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      summary: json['summary'],
      done: json['done'],
    );
  }
}
