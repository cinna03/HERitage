import 'package:coursehub/ui/index.dart';
import 'package:flutter/material.dart';

class Base extends StatefulWidget {
  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {

  int _current = 0;
  final List<Widget> _screens = [
    HomePage(),
    ExplorePage(title: "Explore"),
    SingleCoursePage(),
  ];

  void _onTap(int index) {
    try{
      // Catch RangeError for missing pages
      setState(() {
        _current = index;
      });
    }catch(e){
      // page unimplemented
      print('Missing Page');
    }
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    body: _screens[_current],
    bottomNavigationBar: BottomNavigationBar(
      onTap: _onTap,
      currentIndex: _current,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color.fromARGB(255, 255, 71, 200),
      unselectedItemColor: Color(0xffE9E9EA),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.launch),
          label: "Explore",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_on),
          label: "Courses",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    ),
  );
}}