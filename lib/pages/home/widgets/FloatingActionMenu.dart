import 'dart:math';
import 'package:flutter/material.dart';


/// represents a floating action menu item
/// takes [icon] the icon widget to display when the menu is opened
/// normally the icon is just an [Icon] widget
/// and [title] the title widget to display
/// normally its a [Text] widget
class FloatingActionMenuItem{
  final Widget icon;
  final Widget title;
  const FloatingActionMenuItem({required this.icon , required this.title });
}

/// this class creates a special [FloatingActionButton] that will popup a menu when it's pressed
/// takes these parameters :
/// [icon] the widget to display when the menu is not opened
/// [tappedIcon] the widget to display when the menu is opened
/// [onTab] an event handler for clicking
/// [items] the items on this menu
/// [menuGap] the distance between each item
/// [menuDx] the position of the opened menu
/// [title] the main title of this menu
/// [titleDx] title offset in the X direction
/// [titleDy] title offset in the Y direction
///
class FloatingActionMenu extends StatefulWidget {
  final Widget icon;
  final Widget tappedIcon;
  final void Function() onTab;
  final List<FloatingActionMenuItem> items;
  final double leadingGap;
  final double menuGap;
  final double menuDx;
  final Widget title;
  final double titleDx;
  final double titleDy;

  const FloatingActionMenu({super.key, required this.icon, required this.tappedIcon, required this.onTab , required this.title , this.items = const [] , this.leadingGap = 70 , this.menuGap = 50 , this.menuDx = 5 , this.titleDx = 45, this.titleDy = 25}) ;

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu> with SingleTickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(vsync: this , duration: const Duration(milliseconds: 200),);
  bool _open = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }


  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _controller.value * pi,
      child: Transform.scale(
        scale: _open ? _controller.value < 0.5 ? _controller.value * 0.2 * 2 + 1.0 : (1.0 - _controller.value) * 0.2 * 2 + 1.0 : 1.0,
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          heroTag: "I wasted 2 hours on this ...",
          onPressed: () async {
            if (widget.items.isEmpty && false){
              widget.onTab();
            }else{
              //start the animation
              _open = false;
              _controller.forward(from: 0);
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context , _ , __) => _FabMenuScreen(
                    items: widget.items,
                    tappedIcon: widget.tappedIcon,
                    onTab: widget.onTab,
                    menuDx: widget.menuDx,
                    leadingGap: widget.leadingGap,
                    menuGap: widget.menuGap,
                    title: widget.title,
                    titleDx: widget.titleDx,
                    titleDy: widget.titleDy,
                  ),
                  opaque: false,
                  maintainState: false,

                  transitionsBuilder: (_ , __ , ___ , c) => c,
                ),
              );
              _open = true;
              await Future.delayed(const Duration(milliseconds: 200));
              _controller.reverse(from: 1);
            }
          },
          child: widget.icon,
        ),
      ),
    );
  }
}

class _FabMenuScreen extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final Widget tappedIcon;
  final void Function() onTab;
  final double leadingGap;
  final double menuGap;
  final double menuDx;
  final Widget title;
  final double titleDx;
  final double titleDy;

  const _FabMenuScreen({required this.items, required this.tappedIcon, required this.onTab, required this.leadingGap, required this.menuGap, required this.menuDx, required this.title, required this.titleDx, required this.titleDy});

  @override
  State<_FabMenuScreen> createState() => _FabMenuScreenState();
}

class _FabMenuScreenState extends State<_FabMenuScreen> with SingleTickerProviderStateMixin{
  late final AnimationController _controller = AnimationController(vsync: this , duration: const Duration(milliseconds: 200),);
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward(from: 0);
  }

  List<Widget> _generateMenu(){
    double off = 0;
    return widget.items.map((e) => Positioned(
      bottom: off++ * widget.menuGap + widget.leadingGap,
      right: widget.menuDx,
      child: Row(
        children: [
          e.title,
          Transform.scale(
            scale: _controller.value,
            child: e.icon,
          ),
        ],
      ),
    )
    ).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      bottomNavigationBar: const SizedBox(width: 1,height: 50,),
      floatingActionButton: SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomRight,
          clipBehavior: Clip.none,

          children: [
            FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
                widget.onTab();
              },
              child: Transform.rotate(
                angle: _controller.value * pi - pi,
                child: Transform.scale(
                  scale: _controller.value < 0.5 ? _controller.value * 0.2 * 2 + 1.0 : (1.0 - _controller.value) * 0.2 * 2 + 1.0,
                  child: widget.tappedIcon,
                ),
              ),
            ),
            ..._generateMenu(),
            Positioned(
              right: widget.titleDx,
              bottom: widget.titleDy,
              child: widget.title,
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}

