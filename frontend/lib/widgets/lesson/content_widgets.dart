import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

// --- Animated Content Card ---
class AnimatedContentCard extends StatefulWidget {
  final String title;
  final String content;
  final IconData icon;

  const AnimatedContentCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  State<AnimatedContentCard> createState() => _AnimatedContentCardState();
}

class _AnimatedContentCardState extends State<AnimatedContentCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5), // Use themed card color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: Theme.of(context).colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // --- THIS IS THE FIX ---
                Text(
                  widget.content,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, height: 1.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CodeCard ---
class CodeCard extends StatelessWidget {
  final String content;
  const CodeCard({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final parts = content.split('|||');
    final String description = parts.length > 1 ? parts[0].trim() : '';
    final String code = parts.length > 1 ? parts[1].trim() : parts[0].trim();

    return SingleChildScrollView(
       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Text("Code Example", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: HighlightView(
              code,
              language: 'java',
              theme: monokaiSublimeTheme,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}


const monokaiSublimeTheme = {
  'root': TextStyle(backgroundColor: Color(0xff23241f), color: Color(0xfff8f8f2)),
  'tag': TextStyle(color: Color(0xfff92672)),
  'subst': TextStyle(color: Color(0xfff8f8f2)),
  'strong': TextStyle(color: Color(0xffa6e22e), fontWeight: FontWeight.bold),
  'emphasis': TextStyle(color: Color(0xffa6e22e), fontStyle: FontStyle.italic),
  'bullet': TextStyle(color: Color(0xffae81ff)),
  'quote': TextStyle(color: Color(0xffae81ff)),
  'number': TextStyle(color: Color(0xffae81ff)),
  'regexp': TextStyle(color: Color(0xffae81ff)),
  'literal': TextStyle(color: Color(0xffae81ff)),
  'link': TextStyle(color: Color(0xffae81ff)),
  'code': TextStyle(color: Color(0xffa6e22e)),
  'title': TextStyle(color: Color(0xffa6e22e)),
  'section': TextStyle(color: Color(0xffa6e22e)),
  'selector-class': TextStyle(color: Color(0xffa6e22e)),
  'keyword': TextStyle(color: Color(0xfff92672)),
  'selector-tag': TextStyle(color: Color(0xfff92672)),
  'name': TextStyle(color: Color(0xfff92672)),
  'attr': TextStyle(color: Color(0xfff92672)),
  'symbol': TextStyle(color: Color(0xff66d9ef)),
  'attribute': TextStyle(color: Color(0xff66d9ef)),
  'params': TextStyle(color: Color(0xfff8f8f2)),
  'string': TextStyle(color: Color(0xffe6db74)),
  'type': TextStyle(color: Color(0xffe6db74)),
  'built_in': TextStyle(color: Color(0xffe6db74)),
  'selector-id': TextStyle(color: Color(0xffe6db74)),
  'selector-attr': TextStyle(color: Color(0xffe6db74)),
  'selector-pseudo': TextStyle(color: Color(0xffe6db74)),
  'addition': TextStyle(color: Color(0xffe6db74)),
  'variable': TextStyle(color: Color(0xffe6db74)),
  'template-variable': TextStyle(color: Color(0xffe6db74)),
  'comment': TextStyle(color: Color(0xff75715e)),
  'deletion': TextStyle(color: Color(0xff75715e)),
  'meta': TextStyle(color: Color(0xff75715e)),
};