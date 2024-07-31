// import 'package:flutter/material.dart';
// import 'package:gelbooru/components/pool_list.dart';
// import 'package:gelbooru/constants/color_constants.dart';

// class PoolsScreen extends StatefulWidget {
//   const PoolsScreen({super.key});

//   @override
//   State<PoolsScreen> createState() => _PoolsScreenState();
// }

// class _PoolsScreenState extends State<PoolsScreen> {
//   var _poolList = <String>[];

//   Future<void> _loadPoolList() async {
//   }

//   @override
//   void initState() {
//     super.initState();

//     _loadPoolList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: ColorConstants.primaryColor,
//       ),
//       body: Column(
//         children: [
//           Expanded(child: PoolList(list: _poolList, onTap: (entry) {
            
//           },),)
//         ],
//       ),),
//     );
//   }
// }
