import 'package:flutter/material.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';

// ignore: must_be_immutable
class CardsCarouselWidgetAllmarkets extends StatefulWidget {
  List<Market> marketsList;
  String heroTag;

  CardsCarouselWidgetAllmarkets({Key key, this.marketsList, this.heroTag}) : super(key: key);

  @override
  _CardsCarouselWidgetAllmarketsState createState() => _CardsCarouselWidgetAllmarketsState();
}

class _CardsCarouselWidgetAllmarketsState extends State<CardsCarouselWidgetAllmarkets> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.marketsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.marketsList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/Details',
                  arguments: RouteArgument(
                    id: '0',
                    param: widget.marketsList.elementAt(index).id,
                    heroTag: widget.heroTag,
                  ));
            },
            child: CardWidget(market: widget.marketsList.elementAt(index), heroTag: widget.heroTag),
          );
        },
      ),
    );
  }
}
