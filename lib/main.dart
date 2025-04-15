import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// This would normally be imported, but we'll mock it for now
// import 'package:flutter_gemma/flutter_gemma.dart';

// Mock classes to simulate the flutter_gemma package
class FlutterGemmaPlugin {
  static final FlutterGemmaPlugin instance = FlutterGemmaPlugin();
  late final ModelFileManager modelManager = ModelFileManager();

  Future<MockInferenceModel> createModel({required String modelType, String? preferedBackend, int? maxTokens}) async {
    // Simulate model creation
    await Future.delayed(const Duration(milliseconds: 500));
    return MockInferenceModel();
  }
}

class ModelFileManager {
  Future<bool> isModelInstalled() async {
    // For demonstration, return false to show download flow
    return false;
  }

  Future<void> downloadModelFromNetwork(String url, {String? loraUrl}) async {
    // Simulate downloading
    await Future.delayed(const Duration(seconds: 2));
  }
}

class MockInferenceModel {
  Future<MockChat> createChat({double? temperature, int? topK}) async {
    // Simulate chat creation
    await Future.delayed(const Duration(milliseconds: 300));
    return MockChat();
  }

  Future<void> close() async {
    // Simulate closing
  }
}

class MockChat {
  Future<void> addQueryChunk(Map<String, String> message) async {
    // Simulate adding query
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Stream<String> generateChatResponseAsync() {
    // Simulate streaming response
    return Stream.periodic(
      const Duration(milliseconds: 50),
      (i) => i < 20 ? "This is a simulated response ".split('')[i % 5] : '',
    ).take(20);
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemma Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const GemmaChatScreen(),
    );
  }
}

class GemmaChatScreen extends StatefulWidget {
  const GemmaChatScreen({super.key});

  @override
  State<GemmaChatScreen> createState() => _GemmaChatScreenState();
}

class _GemmaChatScreenState extends State<GemmaChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessageWidget> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isModelLoaded = false;
  bool _isLoading = false;
  bool _isGenerating = false;
  String _loadingStatus = '';
  double _loadingProgress = 0.0;

  late FlutterGemmaPlugin _gemma;
  MockInferenceModel? _inferenceModel;
  MockChat? _chat;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    setState(() {
      _isLoading = true;
      _loadingStatus = 'Initializing plugin...';
    });

    try {
      _gemma = FlutterGemmaPlugin.instance;
      final modelManager = _gemma.modelManager;

      // Check if model is already installed
      final isModelInstalled = await modelManager.isModelInstalled();

      if (!isModelInstalled) {
        setState(() {
          _loadingStatus = 'Model not installed.';
        });

        // In a real app, you would download the model from a server
        // This is just a placeholder for demonstration purposes
        final appSupportDir = await getApplicationSupportDirectory();

        // This is just for UI demonstration - we won't actually download a model
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _loadingStatus = 'Please download a model from https://kaggle.com/models';
          _loadingProgress = 0.3;
        });

        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _loadingStatus = 'For this demo, we\'ll simulate model loading';
          _loadingProgress = 0.6;
        });

        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _loadingStatus = 'In a real app, you would use:';
          _loadingProgress = 0.9;
        });

        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _loadingStatus = 'modelManager.downloadModelFromNetwork(url)';
          _loadingProgress = 1.0;
        });
      } else {
        // Model is installed, let's initialize it
        _inferenceModel = await _gemma.createModel(
          modelType: "gemmaIt", // Or another model type
          preferedBackend: "gpu", // Use GPU if available
          maxTokens: 512,
        );

        _chat = await _inferenceModel!.createChat(temperature: 0.7, topK: 40);

        setState(() {
          _isModelLoaded = true;
          _loadingStatus = 'Model loaded successfully!';
          _loadingProgress = 1.0;

          // Add system message
          _messages.add(
            ChatMessageWidget(
              text: 'Hello! I am Gemma, a lightweight AI assistant. How can I help you today?',
              isUser: false,
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        _loadingStatus = 'Error loading model: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessageWidget(text: text, isUser: true));
      _isGenerating = true;
      _textController.clear();
    });

    // Scroll to bottom
    _scrollToBottom();

    // In a real implementation with an actual model:
    if (_isModelLoaded && _chat != null) {
      try {
        // In a real app with proper imports:
        await _chat!.addQueryChunk({'text': 'User: $text'});

        // Create a temporary message for streaming
        final tempMessageWidget = ChatMessageWidget(text: '', isUser: false);
        setState(() {
          _messages.add(tempMessageWidget);
        });

        // Start streaming response
        _chat!.generateChatResponseAsync().listen(
          (token) {
            setState(() {
              tempMessageWidget.updateText(tempMessageWidget.text + token);
            });
            _scrollToBottom();
          },
          onDone: () {
            setState(() {
              _isGenerating = false;
            });
          },
          onError: (error) {
            setState(() {
              tempMessageWidget.updateText('Error generating response: $error');
              _isGenerating = false;
            });
          },
        );
      } catch (e) {
        // Add error message
        setState(() {
          _messages.add(ChatMessageWidget(text: 'Error: $e', isUser: false));
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    } else {
      // Simulate response for demo purposes
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _messages.add(
          ChatMessageWidget(
            text:
                'This is a simulated response since no model is loaded. In a real implementation, responses would be generated by the Gemma model.',
            isUser: false,
          ),
        );
        _isGenerating = false;
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Gemma Chat'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          if (_isLoading || _loadingProgress < 1.0)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(_loadingStatus),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _loadingProgress),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          if (_isGenerating)
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: LinearProgressIndicator()),
          Container(decoration: BoxDecoration(color: Theme.of(context).cardColor), child: _buildTextComposer()),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(hintText: 'Send a message', border: InputBorder.none),
                onSubmitted: _isGenerating ? null : _handleSubmit,
                enabled: !_isGenerating,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isGenerating ? null : () => _handleSubmit(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _inferenceModel?.close();
    super.dispose();
  }
}

class ChatMessageWidget extends StatefulWidget {
  final bool isUser;
  String text;

  ChatMessageWidget({super.key, required this.text, required this.isUser});

  void updateText(String newText) {
    text = newText;
  }

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor:
                  widget.isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
              child: Icon(widget.isUser ? Icons.person : Icons.smart_toy, color: Colors.white),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.isUser ? 'You' : 'Flutter Gemma', style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(margin: const EdgeInsets.only(top: 5.0), child: Text(widget.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
