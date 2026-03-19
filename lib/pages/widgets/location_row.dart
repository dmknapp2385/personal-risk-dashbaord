import 'package:flutter/material.dart';

class LocationRow extends StatefulWidget {
  const LocationRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<LocationRow> createState() => _LocationRowState();
}

class _LocationRowState extends State<LocationRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant LocationRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location (for crime assessment later)',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Example: 94110, San Francisco, CA',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

