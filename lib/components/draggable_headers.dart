import 'package:flutter/material.dart';

class DraggableHeaders extends StatelessWidget {
  final List<String> headers;
  final List<String> frontFields;
  final List<String> backFields;
  final Function(String, List<String>) onAccept;

  DraggableHeaders({
    required this.frontFields,
    required this.backFields,
    required this.headers,
    required this.onAccept,
  });

  Widget get buildDraggableHeaders {
    return Wrap(
      children: headers.map((header) {
        return Draggable<String>(
          data: header,
          child: Chip(label: Text(header)),
          feedback: Material(
            child: Chip(label: Text(header)),
          ),
          childWhenDragging: Chip(
            label: Text(
              header,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget get buildDragTargets {
    return Column(
      children: [
        buildDragTargetList('Front Fields', frontFields),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        buildDragTargetList('Back Fields', backFields),
      ],
    );
  }

  Widget buildDragTargetList(String title, List<String> targetList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DragTarget<String>(
            onAcceptWithDetails: (data) {
              onAccept(data.data, targetList);
            },
            builder: (context, candidateData, rejectedData) {
              return Wrap(
                children: targetList.map((field) {
                  return Chip(label: Text(field));
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildDraggableHeaders,
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        buildDragTargets,
      ],
    );
  }
}
