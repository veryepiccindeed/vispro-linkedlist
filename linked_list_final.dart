import 'dart:async';
import 'dart:io';
import 'dart:math';

class CharElement {
  String char;
  CharElement? next;

  CharElement(this.char);
}

class CharLinkedList {
  CharElement? head;

  void addCharacter(String char) {
    var newNode = CharElement(char);
    if (head == null) {
      head = newNode;
    } else {
      CharElement temp = head!;
      while (temp.next != null) {
        temp = temp.next!;
      }
      temp.next = newNode;
    }
  }

  String buildString() {
    String result = '';
    for (CharElement? current = head; current != null; current = current.next) {
      result += current.char;
    }
    return result;
  }
}

String generateColor() {
  final rng = Random();
  return '\x1B[38;2;${rng.nextInt(256)};${rng.nextInt(256)};${rng.nextInt(256)}m';
}

void moveCursor(int row, int col) {
  stdout.write('\x1B[${row + 1};${col + 1}H');
}

Future<void> animateText(CharLinkedList charList) async {
  final text = charList.buildString();
  int index = 0;
  int width = stdout.terminalColumns;
  int height = stdout.terminalLines;
  
  while (true) {
    String color = generateColor();
    moveCursor(0, 0); // Move cursor to the top-left corner
    
    for (int line = 0; line < height; line++) {
      if (line.isEven) {
        // Left to right
        for (int col = 0; col < width; col++) {
          moveCursor(line, col);
          stdout.write('${color}${text[index]}\x1B[0m');
          index = (index + 1) % text.length;
          await Future.delayed(Duration(milliseconds: 7));
        }
      } else {
        // Right to left
        for (int col = width - 1; col >= 0; col--) {
          moveCursor(line, col);
          stdout.write('${color}${text[index]}\x1B[0m');
          index = (index + 1) % text.length;
          await Future.delayed(Duration(milliseconds: 7));
        }
      }
    }
    
    // Tunggu sebentar sebelum memulai animasi baru
    await Future.delayed(Duration(seconds: 1));
    
    // Update dimensi terminal untuk setiap siklus baru
    width = stdout.terminalColumns;
    height = stdout.terminalLines;
  }
}

void main() {
  stdout.write('Please enter text for the animation: ');
  String inputText = stdin.readLineSync() ?? '';

  CharLinkedList linkedList = CharLinkedList();
  for (int i = 0; i < inputText.length; i++) {
    linkedList.addCharacter(inputText[i]);
  }

  // Sembunyikan kursor
  stdout.write('\x1B[?25l');
  
  // Bersihkan layar sekali di awal
  stdout.write('\x1B[2J\x1B[H');
  
  animateText(linkedList);
}