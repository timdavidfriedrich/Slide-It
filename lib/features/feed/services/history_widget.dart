import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';

abstract interface class HistoryWidget extends Widget {
  const HistoryWidget({super.key});

  Timestamp getCreatedAt();
}
