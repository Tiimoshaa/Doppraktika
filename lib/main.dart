import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes app')),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://bogatyr.club/uploads/posts/2023-03/thumbs/1678821186_bogatyr-club-p-fon-dlya-zametok-foni-vkontakte-67.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionScreen())),
                  child: Text('Старт'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
                  child: Text('Профиль'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ThemeSwitcher(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String firstName = '';
  String lastName = '';
  final profilePictureUrl = 'https://www.sdp.ulaval.ca/blogue/wp-content/uploads/2016/02/shutterstock_201571106.jpg';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      firstNameController.text = firstName;
      lastNameController.text = lastName;
    });
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', firstNameController.text);
    await prefs.setString('lastName', lastNameController.text);
    setState(() {
      firstName = firstNameController.text;
      lastName = lastNameController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Имя и фамилия сохранены')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(profilePictureUrl)),
            SizedBox(height: 20),
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'Имя')),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Фамилия')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveUserData, child: Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class ThemeSwitcher extends StatefulWidget {
  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool isDarkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          isDarkModeEnabled = !isDarkModeEnabled;
          ThemeManager.applyTheme(isDarkModeEnabled ? ThemeData.dark() : ThemeData.light());
        });
      },
      child: Icon(isDarkModeEnabled ? Icons.nightlight_round : Icons.wb_sunny),
    );
  }
}

class ThemeManager {
  static void applyTheme(ThemeData theme) {
    runApp(MaterialApp(theme: theme, darkTheme: theme, home: HomeScreen()));
  }
}

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выбор')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlatformInfoScreen())),
              child: Text('Информация о платформе'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NoteScreen())),
              child: Text('Заметки'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNotesScreen())),
              child: Text('Просмотр заметок'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String platform = Platform.isAndroid
        ? 'Android'
        : Platform.isIOS
        ? 'iOS'
        : Platform.isMacOS
        ? 'MacOS'
        : Platform.isWindows
        ? 'Windows'
        : 'Other';

    return Scaffold(
      appBar: AppBar(title: Text('Информация о платформе')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Платформа: $platform'),
            SizedBox(height: 20),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK')),
          ],
        ),
      ),
    );
  }
}

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final noteController = TextEditingController();
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList('notes');
    if (notesJson != null) {
      setState(() {
        notes = notesJson.map((noteJson) => Note.fromJson(jsonDecode(noteJson))).toList();
      });
    }
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заметки'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                notes.clear();
                saveNotes();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notes[index].text),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          notes.removeAt(index);
                          saveNotes();
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: noteController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Введите вашу заметку',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  notes.add(Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: noteController.text,
                  ));
                  noteController.clear();
                  saveNotes();
                });
              },
              child: Text('Добавить заметку'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewNotesScreen extends StatefulWidget {
  @override
  _ViewNotesScreenState createState() => _ViewNotesScreenState();
}

class _ViewNotesScreenState extends State<ViewNotesScreen> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList('notes');
    if (notesJson != null) {
      setState(() {
        notes = notesJson.map((noteJson) => Note.fromJson(jsonDecode(noteJson))).toList();
      });
    }
  }

  Future<void> saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Просмотр заметок'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                notes.clear();
                saveNotes();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(notes[index].text),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  Note? editedNote = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(note: notes[index]),
                    ),
                  );
                  if (editedNote != null) {
                    setState(() {
                      notes[index] = editedNote;
                      saveNotes();
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  final Note note;

  EditNoteScreen({required this.note});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    noteController = TextEditingController(text: widget.note.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Редактировать заметку'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.note.text = noteController.text;
              Navigator.of(context).pop(widget.note);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Введите вашу заметку',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class Note {
  String id;
  String text;

  Note({
    required this.id,
    required this.text,
  });

  Note.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
  };
}
