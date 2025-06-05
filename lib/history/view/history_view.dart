import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodel/history_viewmodel.dart';
import '../../core/widgets/colors.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  // HistoryView için linter hatalarını gidermek amacıyla eklenen yorum.
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      context.read<HistoryViewModel>().onDaySelected(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Geçmiş', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
          ),
          body: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: colorss.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: colorss.primaryColor.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: null,
                      decoration: TextDecoration.none),
                  weekendTextStyle: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      height: null,
                      decoration: TextDecoration.none),
                  holidayTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      height: null,
                      decoration: TextDecoration.none),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      height: null,
                      decoration: TextDecoration.none),
                  todayTextStyle: const TextStyle(
                      color: Colors.white,
                      height: null,
                      decoration: TextDecoration.none),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      height: null,
                      decoration: TextDecoration.none),
                  leftChevronIcon: const Icon(Icons.chevron_left,
                      color: Colors.black, size: 30),
                  rightChevronIcon: const Icon(Icons.chevron_right,
                      color: Colors.black, size: 30),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  headerMargin: const EdgeInsets.only(bottom: 16.0),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final moodColor = viewModel.getMoodColorForDay(date);
                    if (moodColor != Colors.transparent) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: moodColor,
                            shape: BoxShape.circle,
                          ),
                          width: 8.0,
                          height: 8.0,
                        ),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    final moodColor = viewModel.getMoodColorForDay(day);
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: moodColor != Colors.transparent
                            ? moodColor.withOpacity(0.8)
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: moodColor != Colors.transparent
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: viewModel.selectedDaySummary == null
                    ? const Center(
                        child: Text(
                          'Seçilen güne ait özet bulunamadı.',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Builder(
                          builder: (context) {
                            final summary = viewModel.selectedDaySummary!;
                            final Color moodBaseColor =
                                viewModel.getMoodColorForDay(summary.timestamp);
                            final Color cardColor = moodBaseColor;
                            final Color textColor =
                                moodBaseColor.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white;

                            return Card(
                              color: cardColor,
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              elevation: 2,
                              shadowColor: Colors.grey.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Özet: ${summary.summary}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ruh Hali: ${summary.mood ?? "Bilinmiyor"} ${viewModel.getMoodEmoji(summary.mood)}',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                          height: null,
                                          decoration: TextDecoration.none),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tarih: ${summary.timestamp.day}.${summary.timestamp.month}.${summary.timestamp.year}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: textColor,
                                          height: null,
                                          decoration: TextDecoration.none),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
