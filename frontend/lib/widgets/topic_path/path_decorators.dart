// // lib/widgets/topic_path/path_decorators.dart
// import 'package:flutter/material.dart';

// class StartNode extends StatelessWidget {
//   final Offset position;
//   const StartNode({super.key, required this.position});
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: position.dy,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
//           ),
//           child: const Text("Start", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
//         ),
//       ),
//     );
//   }
// }

// class FinishNode extends StatelessWidget {
//   final Offset position;
//   const FinishNode({super.key, required this.position});
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: position.dy,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 80),
//             const SizedBox(height: 8),
//             const Text("Topic Complete!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
// }