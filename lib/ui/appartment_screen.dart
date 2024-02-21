import 'package:flutter/material.dart';
import 'package:home_info_client/network/home_api.dart';
import 'package:home_info_client/network/nodes_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/loading_circle.dart';
import 'package:photo_view/photo_view.dart';

class ApartmentScreen extends StatefulWidget {
  @override
  State<ApartmentScreen> createState() => _ApartmentScreenState();
}

class _ApartmentScreenState extends State<ApartmentScreen> {
  List<String>? dates;
  late int dateIndex;
  late String selectedDate;
  bool isCurrent = true;

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      backgroundDecoration: BoxDecoration(
        color: BasicPalette.backgroundColor,
      ),
      loadingBuilder: (context, chunk) {
        return const Center(
          child: LoadingCircle(),
        );
      },
      imageProvider: Image.network('${HomeApi.BASE_URL}/climate-log/222').image,
    );
    // return Column(
    //   children: [
    //     Row(
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.all(4.0),
    //           child: TextButton(
    //             onPressed: () {
    //               setState(() {
    //                 isCurrent = true;
    //               });
    //             },
    //             child: Text(
    //               'Now',
    //               style: TextStyle(
    //                 color: isCurrent ? Colors.white : BasicPalette.accentColor,
    //               ),
    //             ),
    //             style: ButtonStyle(
    //               backgroundColor: MaterialStatePropertyAll(
    //                 isCurrent ? BasicPalette.primaryColor : Colors.transparent,
    //               ),
    //             ),
    //           ),
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.all(4.0),
    //           child: TextButton(
    //             onPressed: () {
    //               setState(() {
    //                 isCurrent = false;
    //               });
    //             },
    //             child: Text(
    //               'Date',
    //               style: TextStyle(
    //                 color: isCurrent ? BasicPalette.accentColor : Colors.white,
    //               ),
    //             ),
    //             style: ButtonStyle(
    //               backgroundColor: MaterialStatePropertyAll(
    //                 isCurrent ? Colors.transparent : BasicPalette.primaryColor,
    //               ),
    //             ),
    //           ),
    //         ),
    //         FutureBuilder(
    //           future: NodesApi.dates(),
    //           builder: (context, snapshot) {
    //             if (snapshot.hasData) {
    //               setState(() {
    //                 List<String> dts = snapshot.data as List<String>;
    //                 dates = dts;
    //                 dateIndex = dts.length - 1;
    //                 selectedDate = dts[dateIndex];
    //               });
    //             }
    //             return const SizedBox.shrink();
    //           },
    //         ),
    //         dates != null
    //             ? Row(
    //                 children: [
    //                   IconButton(
    //                     onPressed: () {
    //                       setState(() {
    //                         int prev = dateIndex - 1;
    //                         if (prev > 0) {
    //                           dateIndex--;
    //                           selectedDate = dates![dateIndex];
    //                         }
    //                       });
    //                     },
    //                     icon: Icon(
    //                       Icons.fast_rewind_outlined,
    //                       color: BasicPalette.primaryColor,
    //                     ),
    //                   ),
    //                   Text(
    //                     selectedDate,
    //                     style: TextStyle(color: BasicPalette.accentColor),
    //                   ),
    //                   IconButton(
    //                     onPressed: () {
    //                       setState(() {
    //                         int next = dateIndex + 1;
    //                         if (next < dates!.length) {
    //                           dateIndex++;
    //                           selectedDate = dates![dateIndex];
    //                         }
    //                       });
    //                     },
    //                     icon: Icon(
    //                       Icons.fast_forward_outlined,
    //                       color: BasicPalette.primaryColor,
    //                     ),
    //                   ),
    //                 ],
    //               )
    //             : const SizedBox.shrink()
    //       ],
    //     ),
    //     Image.network('${HomeApi.BASE_URL}/climate-log/222'),
    //   ],
    // );
  }
}
