import 'package:flutter/material.dart';

void main() async {
  runApp(new MGC());
}

class MGC extends StatelessWidget {
  MGC();
  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatefulWidget {
  App();
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  List<Item> items;
  AppState() {
    this.items = new List<Item>();
  }
  bool showGravyard;
  @override
  Widget build(BuildContext context) {
    var stack = Stack(
      children: <Widget>[
        for (var item in this.items)
          if (!item.graveyard)
            StatelessCard(
                item.position,
                item.tapped,
                (offset, tapped, graveyard) => setState(() {
                      item.position = offset;
                      item.tapped = tapped;
                      item.graveyard = graveyard;
                    })),
        Graveyard(
          () => setState(() {
            this.showGravyard = true;
          }),
        ),
      ],
    );
    return MaterialApp(
      home: Scaffold(
        body: stack,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              this.items.add(Item(Offset(0, 0), false));
            });
          },
          label: Text('Draw'),
          icon: Icon(Icons.bolt),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

class Item extends ChangeNotifier {
  Item(Offset position, bool tapped)
      : position = position,
        tapped = tapped;
  Offset position;
  bool tapped;
  bool graveyard;
}

typedef SetItemState = void Function(
    Offset position, bool tapped, bool graveyard);

class StatelessCard extends StatelessWidget {
  final Offset position;
  final SetItemState _setItemState;
  final bool tapped;
  StatelessCard(Offset position, bool tapped, SetItemState _setItemState)
      : position = position,
        tapped = tapped,
        _setItemState = _setItemState;
  graveyard(bool graveyard) {
    this._setItemState(this.position, this.tapped, graveyard);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          child: GestureDetector(
            onTap: () {
              this._setItemState(this.position, !this.tapped, false);
            },
            onDoubleTap: () {},
            child: RotatedBox(
              quarterTurns: this.tapped == true ? 1 : 0,
              child: Image.network(
                "https://static.cardmarket.com/img/fcdc85fba3aee623de0f2df08bb8c1eb/items/1/2ED/5093.jpg",
                height: 200,
                width: 100,
              ),
            ),
          ),
          onDraggableCanceled: (velocity, offset) {
            this._setItemState(offset, this.tapped, false);
          },
          feedback: Container(
            child: Image.network(
              "https://static.cardmarket.com/img/fcdc85fba3aee623de0f2df08bb8c1eb/items/1/2ED/5093.jpg",
              height: 200,
              width: 100,
            ),
          ),
        ));
  }
}

typedef OpenGraveyard = void Function();

class Graveyard extends StatelessWidget {
  final OpenGraveyard open;
  Graveyard(OpenGraveyard open) : open = open;
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      builder: (context, List<String> candidateData, rejectedData) {
        return GestureDetector(
          onTap: () {
            this.open();
          },
          child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Container(
                  color: Colors.black,
                  height: 150.0,
                  width: 150.0,
                ),
              )),
        );
      },
      onWillAccept: (data) {
        return true;
      },
      onAccept: (StatelessCard card) {},
    );
  }
}
