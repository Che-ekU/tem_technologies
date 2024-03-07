import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FileUploadScreen(),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  FileUploadScreenState createState() => FileUploadScreenState();
}

class FileUploadScreenState extends State<FileUploadScreen> {
  File? _file;
  UploadTask? _uploadTask;
  bool _isUploading = false;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
    );
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String fileName = _file!.path.split('/').last;
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      _uploadTask = ref.putFile(_file!);
      await _uploadTask!.whenComplete(() {
        setState(() {
          _isUploading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _file != null
                ? _file!.path.endsWith('.mp4')
                    ? _PreviewVideo(file: _file)
                    : Image.file(_file!)
                : ElevatedButton(
                    onPressed: _selectFile,
                    child: const Text('Select File'),
                  ),
            const SizedBox(height: 20),
            if (_file != null)
              ElevatedButton(
                onPressed: _uploadFile,
                child: const Text('Upload File'),
              ),
            const SizedBox(height: 20),
            if (_isUploading) const CircularProgressIndicator(),
            if (_uploadTask != null)
              StreamBuilder<TaskSnapshot>(
                stream: _uploadTask!.snapshotEvents,
                builder: (context, snapshot) {
                  double progress = snapshot.hasData
                      ? snapshot.data!.bytesTransferred /
                          snapshot.data!.totalBytes
                      : 0;
                  return Column(
                    children: [
                      Text('${(progress * 100).toStringAsFixed(2)}%'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isUploading = false;
                            _uploadTask = null;
                            _file = null;
                          });
                          if (progress == 1) {
                            _selectFile();
                          }
                        },
                        icon: Icon(
                          progress != 1 ? Icons.cancel : Icons.add_to_photos,
                        ),
                      ),
                    ],
                  );
                },
              ),
            if (_file != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isUploading = false;
                    _uploadTask = null;
                    _file = null;
                  });
                },
                icon: const Icon(Icons.cancel),
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewVideo extends StatefulWidget {
  const _PreviewVideo({required this.file});
  final File? file;
  @override
  State<_PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<_PreviewVideo> {
  late final VideoPlayerController controller;
  @override
  void initState() {
    controller = VideoPlayerController.file(widget.file!);
    controller.initialize().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(
          controller,
          key: UniqueKey(),
        ),
      ),
    );
  }
}
