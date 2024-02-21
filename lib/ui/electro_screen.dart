import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:home_info_client/network/electro_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/ui/appartment_screen.dart';
import 'package:home_info_client/ui/electro_chart_widget.dart';
import 'package:home_info_client/utils/json_storage.dart';
import 'package:logging/logging.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  static final Logger _log = Logger('_StatisticScreenState');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: BasicPalette.primaryColor,
            bottom: TabBar(
              indicatorColor: BasicPalette.accentColor,
              tabs: const [
                Tab(
                  icon: Icon(
                    Icons.thermostat_outlined,
                    color: Colors.white,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.electric_bolt_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ApartmentScreen(),
              FutureBuilder(
                future: chart(),
                builder: (context, remoteSnapshot) {
                  if (remoteSnapshot.hasData && remoteSnapshot.data != null) {
                    ChartData chartData = remoteSnapshot.data as ChartData;
                    return Center(child: ElectroChart(chartData: chartData));
                  } else {
                    return const Center(child: Text('Data is not available'));
                  }
                },
              ),
            ],
          )),
    );
  }

  Future<ChartData> chart() async {
    ChartData? remoteChart;
    try {
      remoteChart = await ElectroApi.chart();
    } catch (e) {
      _log.severe(e);
    }

    if (remoteChart != null) {
      _log.info("remote chart loaded");
      ChartData localChart = await ElectroJsonStorage.read();
      if (localChart.electro != null) {
        await ElectroApi.merge(localChart.electro!);
        remoteChart = await ElectroApi.chart();
        await ElectroJsonStorage.write(remoteChart);
      }
      return remoteChart;
    } else {
      _log.info("remote chart not loaded");
      ChartData localChart = await ElectroJsonStorage.read();
      try {
        ElectroApi.merge(localChart.electro!);
      } catch (e) {
        _log.severe(e);
      }
      return localChart;
    }
  }
}
