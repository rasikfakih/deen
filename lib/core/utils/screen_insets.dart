import 'package:flutter/material.dart';

/// First-content offset for screens using extendBodyBehindAppBar:
/// status-bar inset + toolbar + one spacing step, so content never hides
/// under the glass app bar (Design v5 top-leak rule).
double topContentPad(BuildContext context) =>
    MediaQuery.viewPaddingOf(context).top + kToolbarHeight + 16;
