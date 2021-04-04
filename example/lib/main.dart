import 'dart:io';

import 'package:flutter/material.dart';
import 'package:native_screenshot/native_screenshot.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	Widget _imgHolder;

	@override
	void initState() {
		super.initState();

		_imgHolder = Center(
			child: Icon(Icons.image),
		);
	} // initState()

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: Scaffold(
				appBar: AppBar(
					title: Text('NativeScreenshot Example'),
				),
				bottomNavigationBar: ButtonBar(
					alignment: MainAxisAlignment.center,
					children: <Widget>[
						ElevatedButton(
							child: Text('Press to capture screenshot'),
							onPressed: () async {
								String path = await NativeScreenshot.takeScreenshot();

								debugPrint('Screenshot taken, path: $path');

								if( path == null || path.isEmpty ) {
									ScaffoldMessenger.of(context).showSnackBar(
										SnackBar(
											content: Text('Error taking the screenshot :('),
											backgroundColor: Colors.red,
										)
									); // showSnackBar()

									return;
								} // if error

								ScaffoldMessenger.of(context).showSnackBar(
									SnackBar(
										content: Text('The screenshot has been saved to: $path')
									)
								); // showSnackBar()

								File imgFile = File(path);
								_imgHolder = Image.file(imgFile);

								setState(() {});
							},
						)
					],
				),
				body: Container(
					constraints: BoxConstraints.expand(),
					child: _imgHolder,
				),
			),
		);
	} // build()
} // _MyAppState
