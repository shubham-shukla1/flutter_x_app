// import 'package:flutter/material.dart';
// import 'package:webview_flutter/platform_interface.dart';
//
// class WebviewErrorPage extends StatefulWidget {
//   final WebResourceError? webResourceError;
//
//   WebviewErrorPage(
//     this.webResourceError, {
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   _WebviewErrorPageState createState() => _WebviewErrorPageState();
// }
//
// class _WebviewErrorPageState extends State<WebviewErrorPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Unable to load this URL'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               'Failed URL : ${widget.webResourceError!.failingUrl} \n\n\n Description:${widget.webResourceError!.description} ',
//               style: Theme.of(context).textTheme.headline6,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
