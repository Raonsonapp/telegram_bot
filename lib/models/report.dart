/// lib/models/report.dart
/// =====================================================
/// REPORT MODEL – FINAL v5
/// Used for:
/// - Reporting posts
/// - Reporting reels
/// - Reporting comments
/// - Reporting users
/// =====================================================

import 'user.dart';

/// What type of content is reported
enum ReportTargetType {
  user,
  post,
  reel,
  comment,
}

/// Report reasons
enum ReportReason {
  spam,
  nudity,
  violence,
  hateSpeech,
  harassment,
  misinformation,
  copyright,
  other,
}

class Report {
  // ================= IDENTITY =================
  final int id;

  // ================= ACTOR =================
  /// User who sent report
  final User reporter;

  // ================= TARGET =================
  final ReportTargetType targetType;
  final int targetId;

  // ================= CONTENT =================
  final ReportReason reason;
  final String? description;

  // ================= STATUS =================
  final bool resolved;

  // ================= TIME =================
  final DateTime createdAt;

  // =====================================================
  // CONSTRUCTOR
  // =====================================================

  const Report({
    required this.id,
    required this.reporter,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.description,
    required this.resolved,
    required this.createdAt,
  });

  // =====================================================
  // FROM JSON (BACKEND → APP)
  // =====================================================

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      reporter: User.fromJson(json['reporter']),
      targetType: _parseTargetType(json['target_type']),
      targetId: json['target_id'] as int,
      reason: _parseReason(json['reason']),
      description: json['description'],
      resolved: json['resolved'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // =====================================================
  // TO JSON (APP → BACKEND)
  // =====================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter': reporter.toJson(),
      'target_type': targetType.name,
      'target_id': targetId,
      'reason': reason.name,
      'description': description,
      'resolved': resolved,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // =====================================================
  // HELPERS
  // =====================================================

  static ReportTargetType _parseTargetType(String? value) {
    switch (value) {
      case 'user':
        return ReportTargetType.user;
      case 'post':
        return ReportTargetType.post;
      case 'reel':
        return ReportTargetType.reel;
      case 'comment':
        return ReportTargetType.comment;
      default:
        return ReportTargetType.post;
    }
  }

  static ReportReason _parseReason(String? value) {
    switch (value) {
      case 'spam':
        return ReportReason.spam;
      case 'nudity':
        return ReportReason.nudity;
      case 'violence':
        return ReportReason.violence;
      case 'hateSpeech':
        return ReportReason.hateSpeech;
      case 'harassment':
        return ReportReason.harassment;
      case 'misinformation':
        return ReportReason.misinformation;
      case 'copyright':
        return ReportReason.copyright;
      default:
        return ReportReason.other;
    }
  }

  /// Human readable label
  String get reasonLabel {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.nudity:
        return 'Nudity or sexual content';
      case ReportReason.violence:
        return 'Violence';
      case ReportReason.hateSpeech:
        return 'Hate speech';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.misinformation:
        return 'False information';
      case ReportReason.copyright:
        return 'Copyright violation';
      case ReportReason.other:
        return 'Other';
    }
  }

  @override
  String toString() {
    return 'Report($targetType #$targetId by ${reporter.username}, resolved: $resolved)';
  }
}
