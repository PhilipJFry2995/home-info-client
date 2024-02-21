import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:home_info_client/network/electro_api.dart';
import 'package:home_info_client/resources/palettes.dart';
import 'package:home_info_client/resources/styles.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ElectroChart extends StatefulWidget {
  final ChartData chartData;

  const ElectroChart({Key? key, required this.chartData}) : super(key: key);

  @override
  State<ElectroChart> createState() => _ElectroChartState();
}

class _ElectroChartState extends State<ElectroChart> {
  DateTime from = DateTime.now().subtract(const Duration(days: 3));
  DateTime to = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    TooltipBehavior tooltipBehaviour = TooltipBehavior(
      enable: true,
      color: BasicPalette.primaryColor,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        DateTimeData period = data as DateTimeData;
        String date = DateFormat.yMMMd().format(period.date);
        String start = DateFormat.Hms().format(period.start);
        String end = DateFormat.Hms().format(period.end);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('$date\n$start - \n$end',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        );
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              children: [
                Text(
                  DateFormat.yMMMd().format(from),
                  style: BasicStyles.primaryTextStyle,
                ),
                IconButton(
                  onPressed: showPickerDialog,
                  icon: Icon(
                    Icons.date_range,
                    color: BasicPalette.accentColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  DateFormat.yMMMd().format(to),
                  style: BasicStyles.primaryTextStyle,
                ),
                IconButton(
                  onPressed: showPickerDialog,
                  icon: Icon(
                    Icons.date_range,
                    color: BasicPalette.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
            child: SfCartesianChart(
          tooltipBehavior: tooltipBehaviour,
          zoomPanBehavior: ZoomPanBehavior(
            zoomMode: ZoomMode.x,
            enablePanning: true,
          ),
          palette: <Color>[
            BasicPalette.accentColor,
            Colors.black,
            Colors.grey,
            const Color.fromRGBO(153, 0, 0, 1.0),
          ],
          primaryXAxis: DateTimeAxis(
            interval: 1,
            intervalType: DateTimeIntervalType.days,
          ),
          primaryYAxis: NumericAxis(
              minimum: 0.0,
              maximum: 86400.0,
              interval: 3600,
              axisLabelFormatter: (details) {
                String text = '${(details.value ~/ 3600).toInt()}:00';
                return ChartAxisLabel(text, null);
              }),
          series: series(widget.chartData),
        )),
      ],
    );
  }

  List<RangeColumnSeries<DateTimeData, DateTime>> series(ChartData chartData) {
    return [
      RangeColumnSeries<DateTimeData, DateTime>(
        dataSource: convert(chartData.electro!),
        xValueMapper: (DateTimeData data, _) => data.date,
        highValueMapper: (DateTimeData data, _) => data.highSeconds(),
        lowValueMapper: (DateTimeData data, _) => data.lowSeconds(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        width: 0.8,
      ),
      RangeColumnSeries<DateTimeData, DateTime>(
        dataSource: schedule(chartData.sch!, 'black'),
        xValueMapper: (DateTimeData data, _) => data.date,
        highValueMapper: (DateTimeData data, _) => data.highSeconds(),
        lowValueMapper: (DateTimeData data, _) => data.lowSeconds(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        width: 0.3,
      ),
      RangeColumnSeries<DateTimeData, DateTime>(
        dataSource: schedule(chartData.sch!, 'gray'),
        xValueMapper: (DateTimeData data, _) => data.date,
        highValueMapper: (DateTimeData data, _) => data.highSeconds(),
        lowValueMapper: (DateTimeData data, _) => data.lowSeconds(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        width: 0.3,
      ),
      RangeColumnSeries<DateTimeData, DateTime>(
        dataSource: schedule(generatorSchedule(), 'light'),
        xValueMapper: (DateTimeData data, _) => data.date,
        highValueMapper: (DateTimeData data, _) => data.highSeconds(),
        lowValueMapper: (DateTimeData data, _) => data.lowSeconds(),
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        width: 0.4,
      ),
    ];
  }

  List<DateTimeData> convert(ElectroDto dto) {
    List<ElectroDate> dates = dto.dates;
    List<DateTimeData> data = [];
    for (var element in dates) {
      DateTime date = DateTime.parse(element.date);
      if (date.isBefore(from) || date.isAfter(to)) {
        continue;
      }
      var periods = element.periods.map((period) {
        String startString = period['key'];
        String? endString = period['value'];

        DateTime start = DateTime.parse(startString);
        DateTime end =
            endString == null ? DateTime.now() : DateTime.parse(endString);
        return DateTimeData(date, start, end);
      });
      data.addAll(periods);
    }
    return data;
  }

  List<DateTimeData> schedule(ScheduleDto dto, String zone) {
    List<DateTimeData> data = [];
    var week = [
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now().subtract(const Duration(days: 2)),
      DateTime.now().subtract(const Duration(days: 3)),
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
      DateTime.now().add(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 3)),
    ];

    for (var weekday in week) {
      List<Map<String, dynamic>>? zoneSchedule;
      for (var sch in dto.dates) {
        if (sch.day == weekday.weekday) {
          zoneSchedule = sch.zone(zone);
          break;
        }
      }

      if (zoneSchedule == null) {
        continue;
      }

      var periods = zoneSchedule.map((period) {
        DateTime start = DateTime(
          weekday.year,
          weekday.month,
          weekday.day,
          int.parse(period['key'].split(":")[0]),
          int.parse(period['key'].split(":")[1]),
        );
        DateTime end = DateTime(
          weekday.year,
          weekday.month,
          weekday.day,
          int.parse(period['value'].split(":")[0]),
          int.parse(period['value'].split(":")[1]),
        );
        return DateTimeData(
            DateTime(weekday.year, weekday.month, weekday.day), start, end);
      });
      data.addAll(periods);
    }
    return data;
  }

  void showPickerDialog() {
    showModal<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width * 0.8,
            child: SfDateRangePicker(
              monthViewSettings:
                  const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: DateTime.parse(widget.chartData.electro!.dates[0].date),
              maxDate: DateTime.parse(widget.chartData.electro!
                      .dates[widget.chartData.electro!.dates.length - 1].date)
                  .add(const Duration(days: 3)),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                PickerDateRange range = args.value as PickerDateRange;
                if (range.endDate != null) {
                  from = range.startDate!;
                  to = range.endDate!;
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      },
    ).then((value) => setState(() {}));
  }

  ScheduleDto generatorSchedule() {
    return ScheduleDto(List<ScheduleDate>.generate(7, (index) {
      int dayOfWeek = index + 1;
      return ScheduleDate(dayOfWeek, [], [], [], light: [
        {"key": "07:00", "value": "11:00"},
        {"key": "14:00", "value": "16:00"},
        {"key": "18:30", "value": "23:00"},
      ]);
    }));
  }
}

class DateTimeData {
  final DateTime date;
  final DateTime start;
  final DateTime end;

  DateTimeData(this.date, this.start, this.end);

  num highSeconds() => end.hour * 3600 + end.minute * 60 + end.second;

  num lowSeconds() => start.hour * 3600 + start.minute * 60 + start.second;
}
