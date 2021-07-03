import 'dart:math';
import 'package:flutter/material.dart' as Material;
import 'package:image/image.dart';
import 'dart:io';
import 'dart:ui' as F;
import 'package:flutter/services.dart' show rootBundle;
import 'package:color_convert/color_convert.dart' as Convert;
import 'package:sicma/frontEnd/components/cam/points.dart';
import 'package:path_provider/path_provider.dart';

/*Future<Image> gaussProcess(File f) async {
  Image image = decodeImage(f.readAsBytesSync());
  
  dynamic gausblur = await ImgProc.gaussianBlur(f.readAsBytesSync(), [5,5], 0);
  return Image.fromBytes(image.width, image.height, gausblur);
}*/

void segmentHSV(List paths) async {
  
  print(paths[0]);

  List<double> mingreenHSV = [100.0, 30.0, 27.0], maxgreenHSV = [175, 100, 100];
  List<double> minblueHSV = [150, 35.0, 30.0], maxblueHSV = [240, 100, 100];

  Image image = decodeImage(File(paths[0]).readAsBytesSync());

  print(image.width);
  print(image.height);
  bool bluent = true;
  var bluestandart = [0, 0, 0];
  int div = 0;
  for (var i = 0; i < image.width; i++) {
    for (var j = image.height - 1; j >= 0; j--) {
      F.Color c = F.Color(image.getPixel(i, j));
      var cHSV = Convert.convert.rgb.hsv(c.red, c.green, c.blue);

      //print(Convert.convert.rgb.hsv(c.red, c.green, c.blue));
      //if green
      if ((cHSV[0] >= mingreenHSV[0] && cHSV[0] <= maxgreenHSV[0]) &&
          (cHSV[1] >= mingreenHSV[1] && cHSV[1] <= maxgreenHSV[1]) &&
          (cHSV[2] >= mingreenHSV[2] && cHSV[2] <= maxgreenHSV[2])) {
        image.setPixel(i, j, Material.Colors.white.value);
        //
        //print(cHSV);
        //else if blue

      } else if (bluent && i == 0) {
        bluestandart[0] += cHSV[0];
        bluestandart[1] += cHSV[1];
        bluestandart[2] += cHSV[2];
        div++;
        //print(minblueHSV);
        //print(maxblueHSV);
        image.setPixel(i, j, Material.Colors.green.value);
        print(cHSV);
        print(i.toString() + " " + j.toString());
      } else if ((cHSV[0] >= minblueHSV[0] && cHSV[0] <= maxblueHSV[0]) &&
          (cHSV[1] >= minblueHSV[1] && cHSV[1] <= maxblueHSV[1]) &&
          (cHSV[2] >= minblueHSV[2] && cHSV[2] <= maxblueHSV[2])) {
        image.setPixel(i, j, Material.Colors.green.value);
        //print("Verde");
        //print(cHSV);
      } else
        image.setPixel(i, j, Material.Colors.black.value);
      //print(i.toString()+" "+j.toString());

    }
    bluent = false;
    minblueHSV = [
      bluestandart[0] / div - 40.0,
      bluestandart[1] / div - 25.0,
      bluestandart[2] / div - 25.0
    ];
    maxblueHSV = [
      bluestandart[0] / div + 40.0,
      bluestandart[1] / div + 25.0,
      bluestandart[2] / div + 25.0
    ];
  }

  print("Finiched");
  File(paths[0]).writeAsBytesSync(encodeJpg(image));
  
  //File f = await getImageFileFromAssets('binarized1.png');
  File f2 = await getImageFileFromAssets('binarized2.png');
  
  //Image fixed = decodeImage(f.readAsBytesSync());
  Image fixed2 = decodeImage(f2.readAsBytesSync());
  
  
    Tagging tag = Tagging(image,fixed2);
    tag.buscarEtiquetas();
    MeasureSet ms = MeasureSet(tag);
  
  //print("Hola");
  //ms.printear();
}

List<double> rgb_to_hsv(double r, double g, double b) {
  double maxc = max(r, max(g, b));
  double minc = min(r, min(g, b));

  double v = maxc;
  if (minc == maxc) return [0.0, 0.0, v];

  double s = (maxc - minc) / maxc;
  double rc = (maxc - r) / (maxc - minc);
  double gc = (maxc - g) / (maxc - minc);
  double bc = (maxc - b) / (maxc - minc);

  double h;
  if (r == maxc)
    h = bc - gc;
  else if (g == maxc)
    h = 2.0 + rc - bc;
  else
    h = 4.0 + gc - rc;
  h = (h / 6.0) % 1.0;
  //print([h, s, v]);
  return [h * 360, s * 255, v * 255];
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/images/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}