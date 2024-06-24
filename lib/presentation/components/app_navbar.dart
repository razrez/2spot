import 'package:flutter/material.dart';
import 'package:to_spot/presentation/components/map_screen.dart';

import '../pages/collections_list.dart';
import '../pages/spots_list.dart';


class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.lightBlueAccent[100],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.collections),
            icon: Icon(Icons.collections_outlined),
            label: 'Spots',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border),
            label: 'Collections',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.place),
            icon: Icon(Icons.place_outlined),
            label: 'Map',
          ),
        ],
      ),
      body: <Widget>[
        /// Spots page
        const SpotsListPage(),

        /// Collections page
        const CollectionsListPage(),

        /// Map page
        const MapScreen(),

      ][currentPageIndex],
    );
  }
}