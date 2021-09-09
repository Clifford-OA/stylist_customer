import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stylist_customer/constant.dart';

class TextInputField extends StatefulWidget {
  const TextInputField({
    required this.icon,
    required this.hint,
    required this.inputType,
    required this.inputAction,
    required this.onChanged,
    this.formatters
  });

  final IconData icon;
  final String hint;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Function(String) onChanged;
  final formatters;

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        height: size.height * 0.08,
        width: size.width * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey[500]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: TextField(
            inputFormatters: widget.formatters,
            //  [
            //    widget.inputType == TextInputType.number
            //    ? FilteringTextInputFormatter.digitsOnly 
            //    : widget.inputType == TextInputType.emailAddress 
            //    ? FilteringTextInputFormatter.allow(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")) 
            //    : FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
            // ],
            onChanged: widget.onChanged,
            controller: _email,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: kWhite,
                ),
              ),
              hintText: widget.hint,
              hintStyle: kBodyText,
            ),
            style: kBodyText,
            keyboardType: widget.inputType,
            textInputAction: widget.inputAction,
          ),
        ),
      ),
    );
  }
}
