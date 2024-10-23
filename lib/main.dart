import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SimpleUI(),
    );
  }
}

class SimpleUI extends StatefulWidget {
  const SimpleUI({super.key});

  @override
  _SimpleUIState createState() => _SimpleUIState();
}

class _SimpleUIState extends State<SimpleUI> {
  final inputController = TextEditingController();
  String resultText = "";
  List<String> resultList = [];
  String selectedOption = 'Option 1';
  bool isChecked = false;

  Future<void> getOpenAIResponse(String input) async {
    const apiKey = '';
    final url = '';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Organization': 'org-qGKqo4eFq3qP4FoVarwAEhdY',
        'OpenAI-Project': 'proj_rzRFceMjLlY7VWfYPTsNO6we',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an assistant specialized in helping only with calculations.'
          },
          {'role': 'user', 'content': input},
        ],
        'max_tokens': 100,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        print(data);
        resultText = data['choices'][0]['message']['content'];
      });
    } else {
      setState(() {
        resultText =
            'Error ${response.statusCode}: ${response.reasonPhrase}\n${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OpenAI 계산기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: inputController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await getOpenAIResponse(inputController.text);
              },
              child: const Text('계산하기'),
            ),
            const SizedBox(height: 20),
            Text(resultText),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  resultList.add(inputController.text);
                });
              },
              child: const Text('리스트 추가'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  String result = "${inputController.text} - $selectedOption";
                  if (isChecked) {
                    result += " (Enabled)";
                  }
                  resultList.add(result);
                });
              },
              child: const Text('옵션와 르스트 추가'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: resultList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(resultList[index]),
                  );
                },
              ),
            ),
            DropdownButton<String>(
              value: selectedOption,
              items: <String>['Option 1', 'Option 2', 'Option 3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Enable Option'),
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }
}
