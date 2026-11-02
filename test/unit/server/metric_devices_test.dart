import 'package:flutter_test/flutter_test.dart';
import 'package:server_box/data/model/server/gpu.dart';
import 'package:server_box/data/model/server/status_history.dart';
import 'package:server_box/data/provider/server/single.dart';
import 'package:server_box/data/res/status.dart';
import 'package:server_box/view/page/server/card/metric.dart';
import 'package:server_box/view/page/server/detail/metric_devices.dart';

import '../../helpers/spi_fixture.dart';

void main() {
  test('sensors with only the aggregate behind them still draw one', () {
    // An agent's history has one temperature column; the sensors come with
    // the first status, before any live sample has a line per sensor.
    final status = InitStatus.status;
    status.temps.setAll(const {'coretemp': 62.0, 'nvme': 38.0});
    status.history.seed([
      const StatusHistorySample(timeMs: 1000, temp: 60),
      const StatusHistorySample(timeMs: 2000, temp: 61),
    ]);
    final si = ServerState(
      spi: spiFixture(id: 's', name: 'n', ip: 'h', user: 'u'),
      status: status,
    );

    final devices = MetricDevices.of(si, ServerMetricKind.temp)!;
    expect(devices.defaults, ['coretemp']);
  });

  test('GPU picker lists every GPU but starts with the busiest', () {
    final status = InitStatus.status;
    status.gpus = const [
      GpuItem(id: 'nvidia:0', vendor: 'nvidia', name: 'RTX A', utilization: 10),
      GpuItem(id: 'nvidia:1', vendor: 'nvidia', name: 'RTX B', utilization: 75),
    ];
    status.history.add(
      timeMs: 1,
      gpu: 75,
      gpus: const {'nvidia:0': 10, 'nvidia:1': 75},
    );
    final si = ServerState(
      spi: spiFixture(id: 'gpu', name: 'gpu-host', ip: 'h', user: 'u'),
      status: status,
    );

    final devices = MetricDevices.of(si, ServerMetricKind.gpu)!;
    expect(devices.names, ['nvidia:0', 'nvidia:1']);
    expect(devices.defaults, ['nvidia:1']);
    expect(devices.byDevice['nvidia:0'], [10]);
    expect(devices.byDevice['nvidia:1'], [75]);
    expect(devices.label?.call('nvidia:0'), 'GPU 0 · RTX A');
    expect(devices.subtitle('nvidia:1'), contains('75'));
    // Duplicate model names and changing load must not change selection keys.
    status.gpus = const [
      GpuItem(id: 'nvidia:1', vendor: 'nvidia', name: 'RTX A', utilization: 5),
      GpuItem(id: 'nvidia:0', vendor: 'nvidia', name: 'RTX A', utilization: 90),
    ];
    final next = MetricDevices.of(si, ServerMetricKind.gpu)!;
    expect(next.names, devices.names);
    expect(next.defaults, ['nvidia:0']);
    expect(next.label?.call('nvidia:0'), 'GPU 0 · RTX A');
  });
}
