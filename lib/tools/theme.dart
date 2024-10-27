import 'package:flutter/material.dart';

class MyTheme {
  static Color get mainbackground => _mainbackground();
  static Color get background => _background();
  static Color get background2 => _background2();
  static Color get textcolor => _textcolor();
  static Color get mainbutton => _mainbutton();
  static Color get mainbuttontext => _mainbuttontext();

  static Color get themeColor => _themeColor();
  static Color get themeColor2 => _themeColor2();

  static Color get button1 => _button1();
  static Color get button2 => _button2();
  static Color get boxshadow => _boxshadow();
  static Color get highlightcolor => _highlightcolor();

  static Color _mainbackground() {
    return const Color(0xFFDFE0E3);
  }

  static Color _background() {
    return const Color(0xFFF1F1F1);
  }

  static Color _background2() {
    return const Color(0xFFE2E2E2);
  }

  static Color _mainbutton() {
    return const Color(0xFF7DC2CC);
  }

  static Color _mainbuttontext() {
    return const Color(0xFF06ABAD);
  }

  static Color _themeColor() {
    return const Color(0xFF7DC2CC);
  }

  static Color _themeColor2() {
    return const Color(0xFF06ABAD);
  }

  static Color _textcolor() {
    return const Color.fromARGB(255, 11, 18, 34);
  }

  static Color _button1() {
    return const Color.fromARGB(255, 39, 213, 77);
  }

  static Color _button2() {
    return const Color.fromARGB(255, 255, 105, 120);
  }

  static Color _boxshadow() {
    return Colors.transparent;
  }

  static Color _highlightcolor() {
    return const Color.fromARGB(255, 220, 159, 148);
  }
}


// static Color _mainbackground() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 17, 17, 17)
//         : const Color.fromARGB(255, 238, 243, 246);
//   }

//   static Color _background() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 30, 30, 30)
//         : const Color.fromARGB(255, 189, 192, 195);
//   }

//   static Color _background2() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 30, 30, 30)
//         : const Color.fromARGB(255, 207, 207, 207);
//   }

//   static Color _mainbutton() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 43, 51, 44)
//         : const Color.fromARGB(255, 207, 207, 207);
//   }

//   static Color _mainbuttontext() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 0, 141, 64)
//         : const Color.fromARGB(255, 0, 141, 64);
//   }

//   static Color _textcolor() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 253, 254, 255)
//         : const Color.fromARGB(255, 25, 21, 19);
//   }

//   static Color _button1() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 231, 192, 43)
//         : const Color.fromARGB(255, 8, 125, 0);
//   }

//   static Color _button2() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 234, 56, 41)
//         : const Color.fromARGB(255, 228, 86, 75);
//   }

//   static Color _boxshadow() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? Colors.transparent
//         : Colors.transparent;
//     // : Colors.grey.withOpacity(0.5);
//   }

//   static Color _highlightcolor() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 161, 241, 209)
//         : const Color.fromARGB(255, 252, 170, 55);
//   }






// static Color _mainbackground() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? Color.fromARGB(255, 9, 9, 3)
//         : const Color.fromARGB(255, 253, 253, 253);
//   }

//   static Color _background() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 24, 29, 33)
//         : const Color.fromARGB(255, 215, 217, 217);
//   }

//   static Color _textcolor() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 253, 254, 255)
//         : const Color.fromARGB(255, 25, 21, 19);
//   }

//   static Color _button1() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 231, 192, 43)
//         : const Color.fromARGB(255, 55, 69, 67);
//   }

//   static Color _button2() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 234, 56, 41)
//         : const Color.fromARGB(255, 228, 86, 75);
//   }

//   static Color _boxshadow() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? Colors.transparent
//         : Colors.grey.withOpacity(0.5);
//   }

//   static Color _highlightcolor() {
//     return (_prefs.getBool("darkMode") ?? true)
//         ? const Color.fromARGB(255, 7, 241, 228)
//         : const Color.fromARGB(255, 201, 208, 103);
//   }