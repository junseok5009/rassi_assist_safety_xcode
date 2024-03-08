
import 'package:flutter/material.dart';
import 'package:rassi_assist/ui/custom/custom_bubble/CustomBubbleNodeBase.dart';

class CustomBubbleNode extends CustomBubbleNodeBase {
  Key? key;
  num _value = 0;
  List<CustomBubbleNode>? children;
  CustomBubbleOptions? options;
  int? padding;
  WidgetBuilder? builder;
  CustomBubbleNode? parent;

  num get value {
    if (children == null) {
      return _value;
    }
    return children!.fold(0, (a, b) => a + b.value);
  }

  set value(num newValue) {
    if (children == null) {
      _value = newValue;
    }
  }

  CustomBubbleNode.node({
    required this.children,
    this.padding = 0,
    this.options,
  }) : super(index: 0){
    this.children = children ?? [];
    this.padding = padding;
    for (var child in this.children!) {
      _value += child.value;
      child.parent = this;
    }
  }

  CustomBubbleNode.leaf({
    required num value,
    this.key,
    this.builder,
    this.options,
    required int index,
  }) : super(index: index){
    _value = value;
  }


  int get depth {
    int depth = 0;
    CustomBubbleNode? dparent = parent;
    while (dparent != null) {
      dparent = dparent.parent;
      depth++;
    }
    return depth;
  }

  List<CustomBubbleNode> get leaves {
    var leaves = <CustomBubbleNode>[];
    for (var child in children!) {
      if (child.children == null) {
        leaves.add(child);
      } else {
        leaves.addAll([child, ...child.leaves]);
      }
    }
    return leaves;
  }

  List<CustomBubbleNode> get nodes {
    var nodes = <CustomBubbleNode>[];
    for (var child in children!) {
      nodes.add(child);
      if (child.children != null) nodes.addAll(child.nodes);
    }
    return nodes;
  }

  eachBefore(Function(CustomBubbleNode) callback) {
    CustomBubbleNode node = this;
    var nodes = [node];

    while (nodes.isNotEmpty) {
      node = nodes.removeLast();
      callback(node);
      var children = node.children;
      if (children != null) {
        nodes.addAll(children.reversed);
      }
    }
  }

  eachAfter(Function(CustomBubbleNode) callback) {
    CustomBubbleNode node = this;
    var nodes = [node];
    var next = [];

    while (nodes.isNotEmpty) {
      node = nodes.removeLast();
      next.add(node);
      var children = node.children;
      if (children != null) {
        nodes.addAll(children);
      }
    }

    while (next.isNotEmpty && (node = next.removeLast()) != null) {
      callback(node);
    }
  }
}

class CustomBubbleOptions {
  final Color? color;
  final BoxBorder? border;
  final Widget? child;
  GestureTapCallback? onTap;

  CustomBubbleOptions({
    this.color,
    this.border,
    this.child,
    this.onTap,
  });
}
