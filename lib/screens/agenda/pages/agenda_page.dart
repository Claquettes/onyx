import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oloid2/core/extensions/extensions_export.dart';
import 'package:oloid2/core/widgets/common_screen_widget.dart';
import 'package:oloid2/screens/agenda/agenda_export.dart';
import 'package:oloid2/screens/login/login_export.dart';
import 'package:oloid2/screens/settings/settings_export.dart';
import 'package:sizer/sizer.dart';

import '../../../core/widgets/states_displaying/state_displaying_widget_export.dart';

class AgendaPage extends StatelessWidget {
  const AgendaPage({
    Key? key,
  }) : super(key: key);

  static double indexToOffset(int index) {
    return (15.w) * (index);
  }

  @override
  Widget build(BuildContext context) {
    if (context.read<AgendaCubit>().state.status == AgendaStatus.initial) {
      context.read<AgendaCubit>().load(
          dartus: context.read<AuthentificationCubit>().state.dartus!,
          settings: context.read<SettingsCubit>().state.settings);
    }
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (previous, current) =>
          previous.settings.agendaURL != current.settings.agendaURL ||
          previous.settings.fetchAgendaAuto != current.settings.fetchAgendaAuto,
      listener: (context, state) {
        context.read<AgendaCubit>().load(
            dartus: context.read<AuthentificationCubit>().state.dartus!,
            settings: context.read<SettingsCubit>().state.settings);
      },
      child: BlocBuilder<AgendaCubit, AgendaState>(builder: (context, state) {
        if (kDebugMode) {
          print("AgendaState: ${state.status}");
        }
        Widget? headerState;
        if (state.status == AgendaStatus.loading ||
            state.status == AgendaStatus.initial) {
          headerState =
              const LoadingHeaderWidget(message: "Chargement de l'agenda");
        } else if (state.status == AgendaStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Erreur lors du chargement de l'agenda\nEssayez de désactiver la récuperation automatique de l'agenda dans les paramètres",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SettingsCardWidget(
                      name: "Paramètres de l'agenda",
                      widgets: [AgendaUrlParameterWidget()]),
                ],
              ),
            ),
          );
        }
        bool animating = false;
        PageController pageController = PageController();
        ScrollController scrollController = ScrollController(
            initialScrollOffset: indexToOffset(context
                .read<AgendaCubit>()
                .state
                .wantedDate
                .shrink(3)
                .difference(DateTime.now().shrink(3))
                .inDays));

        pageController = PageController(
            initialPage: context.read<AgendaCubit>().state.dayModels.indexWhere(
                (element) =>
                    element.date.shrink(3) ==
                    context.read<AgendaCubit>().state.wantedDate.shrink(3)));

        return BlocListener<AgendaCubit, AgendaState>(
          listener: (context, state) {
            if (scrollController.hasClients && pageController.hasClients) {
              final int pageIndex = context
                  .read<AgendaCubit>()
                  .state
                  .dayModels
                  .indexWhere((element) =>
                      element.date.shrink(3) ==
                      context.read<AgendaCubit>().state.wantedDate.shrink(3));
              if (!animating) {
                pageController.animateToPage(
                  pageIndex,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 500),
                );
                scrollController.animateTo(
                    indexToOffset(context
                        .read<AgendaCubit>()
                        .state
                        .wantedDate
                        .shrink(3)
                        .difference(DateTime.now().shrink(3))
                        .inDays),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              }
              if (pageIndex != pageController.page) {
                animating = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                  animating = false;
                  scrollController.animateTo(
                      indexToOffset(context
                          .read<AgendaCubit>()
                          .state
                          .wantedDate
                          .shrink(3)
                          .difference(DateTime.now().shrink(3))
                          .inDays),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                });
              }
            }
          },
          child: SafeArea(
              child: CommonScreenWidget(
            state: headerState,
            header: context
                    .read<SettingsCubit>()
                    .state
                    .settings
                    .showMiniCalendar
                ? MiniCalendarWidget(
                    scrollController: scrollController,
                    onUpdate: (DateTime newWantedDay) {
                      context
                          .read<AgendaCubit>()
                          .updateDisplayedDate(date: newWantedDay);
                    },
                  )
                : Container(
                    height: 10.h,
                    color: Theme.of(context).cardTheme.color,
                    child: Center(
                      child: Text(
                        'Agenda',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            body: PageView(
              controller: pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                if (context
                    .read<SettingsCubit>()
                    .state
                    .settings
                    .showMiniCalendar) {
                  context.read<AgendaCubit>().updateDisplayedDate(
                      date: context
                          .read<AgendaCubit>()
                          .state
                          .dayModels[index]
                          .date);
                }
              },
              children: context
                  .read<AgendaCubit>()
                  .state
                  .dayModels
                  .map(
                    (day) => SizedBox(
                      height: 10,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 15,
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${day.date.toWeekDayName()} ${day.date.day} ${day.date.toMonthName()}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .color),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text('${day.events.length} évènement(s)'),
                                ]),
                          ),
                          ...day.events.map(
                            (e) => EventWidget(
                              event: e,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  )
                  .toList(),
            ),
            onRefresh: () async {
              context.read<AgendaCubit>().load(
                  dartus: context.read<AuthentificationCubit>().state.dartus!,
                  settings: context.read<SettingsCubit>().state.settings);
              while (context.read<AgendaCubit>().state.status ==
                      AgendaStatus.ready &&
                  context.read<AgendaCubit>().state.status ==
                      AgendaStatus.error) {
                await Future.delayed(const Duration(milliseconds: 100));
              }
              return;
            },
          )),
        );
      }),
    );
  }
}