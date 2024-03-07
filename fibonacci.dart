import 'package:flutter/material.dart';

void main() {
  runApp(const FibonacciApp());
}

class FibonacciApp extends StatelessWidget {
  const FibonacciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FibonacciCalculator(),
    );
  }
}

class FibonacciCalculator extends StatefulWidget {
  const FibonacciCalculator({super.key});

  @override
  FibonacciCalculatorState createState() => FibonacciCalculatorState();
}

class FibonacciCalculatorState extends State<FibonacciCalculator> {
  int _position = 0;
  BigInt _fibonacciValue = BigInt.zero;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fibonacci Calculator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter position',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _position =
                              int.tryParse(_textEditingController.text) ?? 0;
                          _fibonacciValue = fibonacci(_position);
                        });
                      },
                      child: const Text('Calculate Fibonacci'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Fibonacci value at position $_position:',
                    ),
                    Text(
                      '$_fibonacciValue',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BigInt fibonacci(int n) {
    if (n < 0) {
      return BigInt.zero;
    }
    return _fibonacciMemo(n, <int, BigInt>{});
  }

  BigInt _fibonacciMemo(int n, Map<int, BigInt> memo) {
    if (memo.containsKey(n)) {
      return memo[n]!;
    }
    if (n <= 1) {
      return BigInt.from(n);
    }
    BigInt result = _fibonacciMemo(n - 1, memo) + _fibonacciMemo(n - 2, memo);
    memo[n] = result;
    return result;
  }
}
