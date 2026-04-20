import 'package:flutter/material.dart';
import 'tab/home_screen.dart';
import 'tab/trips_screen.dart';
import 'tab/profile_screen.dart';
import 'tab/earnings_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  // TabController will help us to control the index of the screen
  //to be displayed
  TabController? tabController;
  int indexOfSelectedScreen = 0;
// This function will be called when the user clicks on the item in the 
//bottom navigation bar. It will update the index of the selected screen
  whenNavigationBarItemClick(int index) {
    setState(() {
      indexOfSelectedScreen = index;
      tabController!.index = indexOfSelectedScreen;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Initialize the TabController with the length of the screens and the vsync
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //tabBarView will display the screen according to the index
      //of the selected item in the bottom navigation bar
      body: TabBarView(
        // Disable scrolling for the TabBarView
        physics: NeverScrollableScrollPhysics(),
        // Set the controller for the TabBarView
        controller: tabController,
        children: [
          HomeScreen(),
          EarningsScreen(),
          TripsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white10,
        // Set the items for the bottom navigation bar
        items: [
          //0 index of the first item in the bottom navigation bar
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Rides"),
          //1 index of the second item in the bottom navigation bar
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on),label: "Earnings",),
          //2 index of the third item in the bottom navigation bar
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Trips"),
          //3 index of the fourth item in the bottom navigation bar
          BottomNavigationBarItem(icon: Icon(Icons.person_pin_rounded),label: "Info", ),
        ],
        // Set the current index of the selected item in the 
        //bottom navigation bar
        currentIndex: indexOfSelectedScreen,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        // Set the onTap function to update the index of the selected screen
        onTap: whenNavigationBarItemClick,
      ),
    );
  }
}
