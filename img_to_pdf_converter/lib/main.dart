import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'mobile.dart' if (dart.library.html) 'web.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';

import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;

void main() {
  runApp(MyApp());
}

class Help extends GetxController {
  List datalist = [], obs;
  List<Asset> images = <Asset>[].obs;
  List<Filter> filters = presetFiltersList.obs;
  // File imageFile;
  List filterimg = [].obs;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;
  bool splashtimer = true;
  @override
  void initState() {
    super.initState();
    //  createpath();
    Timer(Duration(seconds: 3), () {
      setState(() {
        splashtimer = false;
      });
    });
  }

  List<Filter> presetFiltersList = [
    NoFilter(),
    // XProIIFilter(),
    // AddictiveBlueFilter(),
    // AddictiveRedFilter(),
    // RiseFilter(),
    JunoFilter(),
    // AdenFilter(),
    // AmaroFilter(),
    // AshbyFilter(),
    BrannanFilter(),
    // BrooklynFilter(),
    // CharmesFilter(),
    // ClarendonFilter(),
    // CremaFilter(),
    // DogpatchFilter(),
    // EarlybirdFilter(),
    // F1977Filter(),
    // GinghamFilter(),
    // GinzaFilter(),
    // HefeFilter(),
    // HelenaFilter(),
    // HudsonFilter(),

    // KelvinFilter(),
    // LarkFilter(),
    // LoFiFilter(),
    // LudwigFilter(),
    // MavenFilter(),
    // MayfairFilter(),
    // MoonFilter(),
    // NashvilleFilter(),
    // PerpetuaFilter(),
    // ReyesFilter(),

    // SierraFilter(),
    // SkylineFilter(),
    // SlumberFilter(),
    // StinsonFilter(),
    // SutroFilter(),
    // ToasterFilter(),
    // ValenciaFilter(),
    // VesperFilter(),
    // WaldenFilter(),
    InkwellFilter(),
    // WillowFilter(),
  ];

  // List datalist = [];
  // List<Asset> images = <Asset>[];
  Widget buildGridView() {
    // print(" builde");
    var prohelp = Get.put(Help());
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(
          prohelp.filterimg.isEmpty
              ? prohelp.datalist.length
              : prohelp.filterimg.length, (index) {
        return InkWell(
          onTap: () {
            //print(datalist.length.toString());
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Image.memory(
              prohelp.filterimg.isEmpty
                  ? prohelp.datalist[index]
                  : prohelp.filterimg[index],
              width: 300,
              height: 300,
            ),
          ),
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    var prohelp = Get.put(
      Help(),
    );

    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 100,
        enableCamera: true,
        selectedAssets: prohelp.images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#0f84fa",
          actionBarTitle: "Gallery",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    prohelp.images = resultList;

    resultList.forEach((element) async {
      return await element.getByteData(quality: 20).then((test) {
        ///  print(test.buffer.asUint8List(test.offsetInBytes, test.lengthInBytes));

        prohelp.datalist.add(
            test.buffer.asUint8List(test.offsetInBytes, test.lengthInBytes));
        setState(() {});
      });
    });
  }

  Future getImage(context) async {
    var prohelp = Get.put(Help());
    var i = 0;
    while (i < prohelp.datalist.length) {
      print("i value $i");

      var image =
          imageLib.decodeImage(await FlutterImageCompress.compressWithList(
        prohelp.datalist[i],
        minHeight: 1080,
        minWidth: 1920, //1080
        quality: 20,
        rotate: 0,
      ));
      // var image = imageLib.decodeImage(await prohelp.datalist[i]);
      print("before toimage ");
      // image = imageLib.copyResize(image, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => PhotoFilterSelector(
            circleShape: false,
            title: Text("Filter"),
            image: image,
            filters: presetFiltersList,
            filename: "fileNamesk.png",
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );
      i++;
      print("before to ++++ ");
      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        // setState(() {
        var imageFile = imagefile['image_filtered'];
        // });

        var filteredimg = File(imageFile.path);
        //   print(await filteredimg.readAsBytes());
        print("before file ");
        //  prohelp.filterimg.add(await filteredimg.readAsBytes());

        prohelp.filterimg.add(await FlutterImageCompress.compressWithFile(
          filteredimg.absolute.path,
          minHeight: 1920,
          minWidth: 1080,
          quality: 50,
          rotate: 0,
        ));
        print("beforeto compresser ");
        setState(() {});
      }
    }
  }

  Future<void> _createPDF() async {
    var prohelp = Get.put(Help());

    PdfDocument document = PdfDocument();
    int i = 0;

    List pdflist =
        prohelp.filterimg.isEmpty ? prohelp.datalist : prohelp.filterimg;

    while (i < pdflist.length) {
      print("while");

      document.pages.add().graphics.drawImage(
          PdfBitmap(await pdflist[i]), Rect.fromLTWH(0, 0, 500, 800));

      // document.pages.add().graphics.drawImage(
      //     PdfBitmap.fromBase64String(base64Encode(prohelp.filterimg.first)),
      //     Rect.fromLTWH(0, 0, 500, 1000));
      print(i.toString());

      i++;
    }
    List<int> bytes = document.save();
    document.dispose();

    await saveAndLaunchFile(
      bytes,
    );
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var prohelp = Get.put(Help());
    return splashtimer
        ? Container(
            color: Colors.white,
            child: LottieBuilder.asset("asserts/11564-scanner-animation.json"))
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Image To PDF Converter",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            drawer: Drawer(
              child: SafeArea(
                child: ListView(
                  children: [
                    ListTile(
                      tileColor: Colors.amber[400],
                      contentPadding: EdgeInsets.all(5),
                      title: Image.network(
                          "https://img.utdstc.com/icon/a52/e40/a52e4057dde8ee93a88c7c74225e4c4707289bb83cab97308c9ce4c416f698ca:200"),
                    ),
                    ListTile(
                        tileColor: Colors.amber[400],
                        contentPadding: EdgeInsets.all(0),
                        title: Text(
                          " IMG TO PDF Converter",
                          style: TextStyle(fontSize: 25, color: Colors.black),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
            ),
            body: Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  children: [
                    loading
                        ? Container(
                            height: 610,
                            child: Center(
                              child: Container(
                                  child: CircularProgressIndicator(
                                strokeWidth: 5,
                              )),
                            ),
                          )
                        : (prohelp.filterimg.isEmpty
                                        ? prohelp.datalist
                                        : prohelp.filterimg)
                                    .isEmpty ==
                                true
                            ? Container(
                                height: 610,
                                child: Center(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Text(
                                          "Please Select Image By Press On \n \nLoad Image Button",
                                          style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue[600]),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Container(
                                            height: 300,
                                            width: 300,
                                            // color: Colors.blue,
                                            child: LottieBuilder.asset(
                                                "asserts/pdf.json")),
                                        SizedBox(
                                          height: 50,
                                        ),
                                        Text(
                                          "Image Filter Is Available ",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.blue[300]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : loading
                                ? Container(
                                    height: 610,
                                    child: Center(
                                      child: Container(
                                          child: CircularProgressIndicator(
                                        strokeWidth: 5,
                                      )),
                                    ),
                                  )
                                : Expanded(
                                    child: Container(
                                      child: buildGridView(),
                                      color: Colors.grey[200],
                                    ),
                                  ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(100, 40),
                                  elevation: 3,
                                  side: BorderSide(
                                    width: 3,
                                    color: Colors.deepPurpleAccent.shade100,
                                  )),
                              child: Text('Load Image'),
                              onPressed: () async {
                                prohelp.images.clear();
                                prohelp.datalist.clear();
                                prohelp.filterimg.clear();
                                await loadAssets();
                                Timer(Duration(milliseconds: 100), () async {
                                  setState(() {});
                                });
                              },
                            ),
                            if (prohelp.datalist.isNotEmpty)
                              ElevatedButton(
                                onPressed: () async {
                                  await getImage(context);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                        //  color: Colors.blue[200],
                                        ),
                                    padding: EdgeInsets.all(3),
                                    child: Text("Filter")),
                              ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(100, 40),
                                  elevation: 3,
                                  side: BorderSide(
                                    width: 3,
                                    color: Colors.deepPurpleAccent.shade100,
                                  )),
                              child: Text('Create PDF'),
                              onPressed: () {
                                if (prohelp.images.isNotEmpty)
                                  setState(() {
                                    loading = true;
                                  });
                                prohelp.images.isNotEmpty
                                    ? Get.snackbar('', "",
                                        duration: Duration(seconds: 1),
                                        titleText: Text(
                                          "Note",
                                          style: TextStyle(fontSize: 22),
                                          // textAlign: TextAlign.center,
                                        ),
                                        messageText: Text(
                                          "PDF File Saved in Storage >> IMG_TO_PDF Folder",
                                          style: TextStyle(fontSize: 20),
                                          //  textAlign: TextAlign.center,
                                        ),
                                        backgroundColor: Colors.white)
                                    : Get.snackbar(
                                        'Error', 'Please Select Image',
                                        backgroundColor: Colors.blue[200]);

                                Timer(Duration(milliseconds: 500), () async {
                                  if (prohelp.images.isNotEmpty) {
                                    _createPDF();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

// Future<Uint8List> _readImageData(String name) async {
//   final data = await rootBundle.load('images/$name');
//   return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
// }
