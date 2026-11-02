# Per-GPU live utilization charts

This fork adds a GPU device picker to the server detail page. Open the GPU
chart, then use the device control to select one or more GPUs. Selection uses
GPU IDs, so identical model names remain separate. The default is the busiest
GPU; selecting a single GPU also updates the detail reading and name. The
server list card continues to show the busiest GPU.

Each GPU has its own aligned rolling history. New devices are padded with
missing samples, missing readings break the plotted line, and devices absent
for an entire buffer are removed. Device order and colours remain stable as
load changes. Empty selected histories never fall back to the busiest GPU's
aggregate history.

Only live utilization is covered. Stored monitor history has no per-GPU points;
24-hour and 7-day views still use the agent's aggregate history. GPU temperature,
memory and power histories are outside this change.

Validation commands:

```powershell
flutter test test/unit/server/status_history_test.dart test/unit/server/metric_devices_test.dart test/unit/server/watched_window_test.dart
flutter build windows --release
```

Upstream: https://github.com/lollipopkit/flutter_server_box

Base commit: `605aca4f6aad47e9aee9a6386858d39c79fc3382`.
The original AGPL-3.0 license is retained.

## Reconnect from a failed detail page

When a previously sampled server fails, its error notice above the charts now
shows a refresh icon with a Reconnect tooltip. Pressing it resets the retry
limiter and retries the current server directly. The button is disabled while
connecting or loading. Pressing the error text still opens error details.

Validated on Windows with Flutter 3.47.9 / Dart 3.13.7:

- 24 GPU history, picker and chart-window unit tests passed.
- 3 notice widget tests passed, including separate refresh and details actions.
- Static analysis of changed Dart files passed without issues.
