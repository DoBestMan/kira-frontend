import 'package:fluid_layout/fluid_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/widgets/custom_appbar.dart';
import 'package:kira_auth/widgets/custom_card.dart';

class AppbarWrapper extends StatelessWidget {
  final Widget childWidget;

  const AppbarWrapper({
    this.childWidget,
  }) : super();

  @override
  Widget build(BuildContext context) {
    // Use media query to provude us total height and width of our screen
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: FluidLayout(
            horizontalPadding:
                FluidValue.fromWidth(0, (containerWidth) => null),
            child: Builder(
                builder: (context) => CustomScrollView(slivers: <Widget>[
                      makeCustomAppBar(context),
                      SliverFluidGrid(
                        fluid: true,
                        // spacing: 10,
                        children: [
                          FluidCell.fit(
                              size: context.fluid(12,
                                  xs: 12, s: 12, m: 12, l: 12, xl: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                    // border: Border.all(
                                    //     width: 2, color: Colors.black38),
                                    borderRadius: const BorderRadius.all(
                                        const Radius.circular(8)),
                                    color: Colors.white),
                                // padding: EdgeInsets.all(10),
                                margin: EdgeInsets.symmetric(vertical: 30),
                                child: childWidget,
                              ))
                        ],
                      )
                    ]))),
      ),
    );
  }

  SliverToBoxAdapter makeCustomAppBar(BuildContext context) {
    return SliverToBoxAdapter(
        child: FluidCell.fit(
            size: context.fluid(2),
            child: CustomCard(
                color: KiraColors.kBackgroundColor,
                child: Container(
                  padding: const EdgeInsets.all(0),
                  child: CustomAppBar(),
                ))));
  }
}
