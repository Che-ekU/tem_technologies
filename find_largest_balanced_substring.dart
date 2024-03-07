List<String> getBalancedSubStrings(String input) {
  List<String> result = [];
  int length = input.length;
  int maxLength = 0;

  for (int i = 0; i < length; i++) {
    Map<String, int> charCount = {};
    charCount[input[i]] = 1;

    for (int j = i + 1; j < length; j++) {
      String currentChar = input[j];
      if (charCount.length < 2 ||
          (charCount.containsKey(currentChar) && charCount[currentChar]! > 0)) {
        charCount[currentChar] ??= 0;
        charCount[currentChar] = charCount[currentChar]! + 1;

        if (charCount.length == 2 &&
            charCount.values
                .every((count) => count == charCount.values.first)) {
          int substringLength = j - i + 1;
          if (substringLength > maxLength) {
            maxLength = substringLength;
            result = [input.substring(i, j + 1)];
          } else if (substringLength == maxLength) {
            result.add(input.substring(i, j + 1));
          }
        }
      } else {
        break;
      }
    }
  }

  return result;
}

void main() {
  print(getBalancedSubStrings("cabbacc"));
  print(getBalancedSubStrings("abababa"));
  print(getBalancedSubStrings("aaaaaaa"));
}
