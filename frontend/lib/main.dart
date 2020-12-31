import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';
import 'src/generated/mgc.pb.dart';
import 'src/generated/mgc.pbgrpc.dart';

void main() {
  final c = new Client();
  final myApp = new MyApp();
  c.run();

  runApp(myApp);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: App(),
      ),
    );
  }
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  Color caughtColor = Colors.grey;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DragBox(Offset(300.0, 0.0), 'Black Lotus', Colors.lightGreen),
      ],
    );
  }
}

class DragBox extends StatefulWidget {
  final Offset initPos;
  final String label;
  final Color itemColor;

  DragBox(this.initPos, this.label, this.itemColor);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: position.dx,
        top: position.dy,
        child: Draggable(
          data: widget.itemColor,
          child: Image.network(
            "https://static.cardmarket.com/img/fcdc85fba3aee623de0f2df08bb8c1eb/items/1/2ED/5093.jpg",
            scale: 1.75,
          ),
          onDraggableCanceled: (velocity, offset) {
            setState(() {
              position = offset;
              //FIXME(BJ) how do I send commands to the client?
            });
          },
          feedback: Container(
            child: Image.network(
                "https://static.cardmarket.com/img/fcdc85fba3aee623de0f2df08bb8c1eb/items/1/2ED/5093.jpg",
                scale: 1.75,
                color: Color.fromRGBO(255, 255, 255, 0.1),
                colorBlendMode: BlendMode.modulate),
          ),
        ));
  }
}

class Client {
  GameClient stub;
  String uuid;
  Future<void> run() async {
    final channel = GrpcWebClientChannel.xhr(Uri.http('localhost:9090', ""));
    channel.createConnection();
    stub = GameClient(channel);
    await runConnect();
    await listen();//FIXME(BJ) how do update the widgets?
    await channel.shutdown();
  }

  Future<void> runConnect() async {
    final res = await stub.connect(ConnectRequest());
    this.uuid = res.uuid;
  }

  void execute(Event e) {
    // todo
  }

  Future<void> listen() async {
    final req = ListenRequest();
    req.uuid = this.uuid;
    await for (var res in stub.listen(req)) {
      execute(res.event);
    }
  }
}
