import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:math';
import 'fish.dart';

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
  const AquariumScreen({super.key}); 

  

}

void main() => runApp( MaterialApp(home: AquariumScreen()));

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
   
  List<Fish> fishList = [];
  late AnimationController _controller;
  Random random = Random();

  int fishCount = 0;
  double fishSpeed = 1.0;
  Color defaultFishColor = Colors.blue;
  final dbHelper = DatabaseHelper();

  // Aquarium dimensions
  final double aquariumWidth = 300;
  final double aquariumHeight = 300;

 // Maximum number of fish allowed
   static const int maxFishCount = 3 ;

  @override
  void initState() {
    super.initState();
     _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),)..repeat();
    _loadSettings();
  

  _controller.addListener(() {
      setState(() {
        // Update the fish positions
          for (var fish in fishList) {
              final newX = fish.position.dx + (fish.speed * (random.nextBool() ? 1 : -1));
              final newY = fish.position.dy + (fish.speed * (random.nextBool() ? 1 : -1));

              // Ensure the fish stay within the aquarium bounds
          if (newX >= 0 && newX <= aquariumWidth - 30) {
            fish.position = Offset(newX, fish.position.dy);
          }
          if (newY >= 0 && newY <= aquariumHeight - 30) {
            fish.position = Offset(fish.position.dx, newY);
          }
         }
      });
    });
  }

 // Function to empty the tank
  void _emptyTank() {
    setState(() {
      fishList.clear();
      fishCount = 0;
    });
    _saveSettings();  // Save settings after emptying the tank
  }

  // Function to save settings
  void _saveSettings() async {
    await dbHelper.saveSettings(fishCount, fishSpeed, defaultFishColor.value);
  }

  // Function to load saved settings
  void _loadSettings() async {
    final settings = await dbHelper.loadSettings();
    if (settings != null) {
      setState(() {
        fishCount = settings['fish_count'];
        fishSpeed = settings['default_speed'];
        defaultFishColor = Color(settings['default_color']);
      });
    }
  }

  void _showFishCustomizationDialog() {
  double speed = 1;
  Color selectedColor = Colors.blue;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Customize Fish'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Speed: ${speed.toStringAsFixed(2)}'),
            Slider(
              value: speed,
              min: 0.5,
              divisions: 3,
              max: 3.0,
              onChanged: (value) {
                setState(() {
                  speed = value;
                });
              },
            ),
            Text('Color:'),
            Wrap(
              children: Colors.primaries.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    color: color,
                    margin: EdgeInsets.all(4.0),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              fishCount++;
              setState(() {
                fishList.add(Fish(
                  position: Offset(
                     random.nextDouble() * (aquariumWidth - 30),
                    random.nextDouble() * (aquariumHeight - 30)),
                  color: selectedColor,
                  speed: speed,
                ));
              });
              Navigator.of(context).pop();
            },
            child: Text('Add Fish'),
          ),
        ],
      );
    },
  );
}




 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Aquarium Container
            Container(
              width: aquariumWidth,
              height: aquariumHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: Stack(
                children: fishList.map((fish) => FishWidget(fish: fish)).toList(),
              ),
            ),
             Text('Number of Fish: $fishCount'),
             Text('MAX: $maxFishCount'),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed:  fishCount < maxFishCount ? _showFishCustomizationDialog : null ,
              child: fishCount < maxFishCount ? Text('Add Fish'):Text('TANK FULL') ,

            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _emptyTank,
              child: Text('Empty Tank'),
            )
          
          ],
        ),
      ),
    );
  }
}