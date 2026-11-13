import 'package:code_arrow_creator_studio/blocs/route_guard/route_guard_bloc.dart';
import 'package:code_arrow_creator_studio/main.dart';
import 'package:code_arrow_creator_studio/screens/not_found.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteGuardPage extends StatefulWidget {
  final Widget child;

  const RouteGuardPage({super.key, required this.child});

  @override
  State<RouteGuardPage> createState() => _RouteGuardPageState();
}

class _RouteGuardPageState extends State<RouteGuardPage> {
  Future<String> routeGuard() async {
    sessionData = await storage.readAll();
    return "done";
  }

  RouteGuardBloc routeGuardBloc = RouteGuardBloc();

  @override
  void initState() {
    routeGuardBloc.add(BasicRouteProtection());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RouteGuardBloc, RouteGuardState>(
      bloc: routeGuardBloc,
      listener: (context, state) {},
      builder: (context, state) {
        if (state is NotLoggedIn) {
          return const Error404();
        }
        if (state is LoggedIn) {
          return widget.child;
        }
        return const Scaffold();
      },
    );
  }
}
