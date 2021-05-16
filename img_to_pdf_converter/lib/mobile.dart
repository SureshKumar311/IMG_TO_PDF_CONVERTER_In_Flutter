import 'package:open_file/open_file.dart';

import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<void> saveAndLaunchFile(List<int> bytes, {String fileName}) async {
  DateTime fileName = DateTime.now();

  //final path = (await getExternalStorageDirectory()).path;
  final path = await createpath();
  final file = File('$path/$fileName.pdf');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open('$path/$fileName.pdf');
}

createpath() async {
  await Permission.storage.request();
  Directory path = Directory("storage/emulated/0/IMG_TO_PDF");
  if ((await path.exists())) {
    print("$path");
    return "storage/emulated/0/IMG_TO_PDF";
  } else {
    await path.create();
    print("not exist $path.create() ");

    return "storage/emulated/0/IMG_TO_PDF";
  }
}
