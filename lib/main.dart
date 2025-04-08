import 'package:flutter/material.dart';
import 'pages/record_page.dart';
import 'pages/recordings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hummi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hummi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<RecordPageState> _recordKey = GlobalKey<RecordPageState>();
  late final RecordPage _recordPage;
  final RecordingsPage _recordingsPage = const RecordingsPage();

  @override
  void initState() {
    super.initState();
    _recordPage = RecordPage(key: _recordKey);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_selectedIndex == 0 ? 'Record' : 'Recordings'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_recordPage, _recordingsPage],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic), label: 'Record'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Recordings'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          _selectedIndex == 0
              ? Container(
                height: 80,
                width: 80,
                margin: const EdgeInsets.only(bottom: 16),
                child: FloatingActionButton(
                  onPressed: () {
                    final recordState = _recordKey.currentState;
                    if (recordState != null) {
                      recordState.toggleRecording();
                    }
                  },
                  backgroundColor:
                      _recordKey.currentState?.isRecording == true
                          ? Colors.red
                          : Theme.of(context).colorScheme.primaryContainer,
                  elevation: 4,
                  child: Icon(
                    _recordKey.currentState?.isRecording == true
                        ? Icons.stop
                        : Icons.mic,
                    size: 32,
                  ),
                ),
              )
              : null,
    );
  }
}
