import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/category.dart';
import '../models/route_argument.dart';


// ignore: must_be_immutable
class ViewAllCategoriesCarouselItemWidget extends StatefulWidget {
  double marginLeft;
  Category category;
  ViewAllCategoriesCarouselItemWidget({Key key, this.marginLeft, this.category}) : super(key: key);

  @override
  _ViewAllCategoriesCarouselItemWidgetState createState() => _ViewAllCategoriesCarouselItemWidgetState();
}

class _ViewAllCategoriesCarouselItemWidgetState extends State<ViewAllCategoriesCarouselItemWidget> {


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        FlatButton(
            onPressed: () {

              Navigator.of(context).pushNamed('/Category', arguments: RouteArgument(id: widget.category.id));

            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.all(Radius.circular(5)),
                color: Theme.of(context).accentColor,
              ),
              child: Text(
                  widget.category.name,
                  overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).primaryColor),
              ),
            )
        ),
      ],
    );
  }
}
