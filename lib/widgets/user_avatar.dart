import 'package:flutter/material.dart';
import '../models/user.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final String? name;
  final int? id;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.user,
    this.name,
    this.id,
    this.radius = 20.0,
    this.onTap,
  });

  String _getInitials() {
    if (user != null) {
      return user!.initials;
    }
    final target = name?.trim() ?? '';
    if (target.isEmpty) return '?';
    final parts = target.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getColor() {
    final seed = id ?? (user?.id) ?? (name?.hashCode ?? 0);
    final hue = (seed.abs() * 137.508) % 360; // Golden angle for even distribution
    return HSLColor.fromAHSL(1.0, hue, 0.65, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getColor();
    final initials = _getInitials();

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.85,
          letterSpacing: -0.5,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return avatar;
  }
}
