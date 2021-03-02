import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:markets/generated/l10n.dart';

import '../elements/SearchWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';

class ViewAllSearchBarWidget extends StatelessWidget {
  final List<Market> marketsList;
  final String heroTag;

  const ViewAllSearchBarWidget(
      {Key key, this.marketsList, this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> scanQR() async {
      String barcodeScanRes;
      // Platform messages may fail, so we use a try/catch PlatformException.
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            "#ff6666", "Cancel", true, ScanMode.QR);
        print(barcodeScanRes);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      print(barcodeScanRes);
      Market market =
      marketsList.firstWhere((element) => (element.id == barcodeScanRes));
      Navigator.of(context).pushNamed('/Details',
          arguments: RouteArgument(
            id: '0',
            param: market.id,
            heroTag: heroTag,
          ));
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).push(SearchModal());
      },
      child: Container(
        padding: EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 0),
              child: Icon(Icons.search, color: Theme.of(context).accentColor,size: 18,),
            ),
            Expanded(
              child: Text(
                S.of(context).search_for_markets_or_products,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .merge(TextStyle(fontSize: 13)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
