import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../elements/ViewAllSearchBarWidget.dart';
import '../../generated/l10n.dart';
import '../controllers/category_controller.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FilterWidget.dart';
import '../elements/ProductGridItemWidget.dart';
import '../elements/ProductListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ViewAllCategoryProductsWidget extends StatefulWidget {
  @override
  _ViewAllCategoryProductsWidgetState createState() => _ViewAllCategoryProductsWidgetState();
}

class _ViewAllCategoryProductsWidgetState extends StateMVC<ViewAllCategoryProductsWidget> {
  // TODO add layout in configuration file
  String layout = 'grid';

  CategoryController _con;

  _ViewAllCategoryProductsWidgetState() : super(CategoryController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForallProductsByCategory();
    // _con.listenForCategory(id: widget.id);
    _con.listenForCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _con.refreshCategory,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: ViewAllSearchBarWidget(
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                leading: Icon(
                  Icons.category,
                  color: Theme.of(context).hintColor,
                ),
                title: Text(
                  _con.category?.name ?? 'All',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headline4,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        setState(() {
                          this.layout = 'list';
                        });
                      },
                      icon: Icon(
                        Icons.format_list_bulleted,
                        color: this.layout == 'list' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          this.layout = 'grid';
                        });
                      },
                      icon: Icon(
                        Icons.apps,
                        color: this.layout == 'grid' ? Theme.of(context).accentColor : Theme.of(context).focusColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
            _con.products.isEmpty
                ? CircularLoadingWidget(height: 500)
                : Offstage(
              offstage: this.layout != 'list',
              child: ListView.separated(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                itemCount: _con.products.length,
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                itemBuilder: (context, index) {
                  return ProductListItemWidget(
                    heroTag: 'favorites_list',
                    product: _con.products.elementAt(index),
                  );
                },
              ),
            ),
            _con.products.isEmpty
                ? CircularLoadingWidget(height: 500)
                : Offstage(
              offstage: this.layout != 'grid',
              child: GridView.count(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                primary: false,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                padding: EdgeInsets.symmetric(horizontal: 20),
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 4,
                // Generate 100 widgets that display their index in the List.
                children: List.generate(_con.products.length, (index) {
                  return ProductGridItemWidget(
                      heroTag: 'category_grid',
                      product: _con.products.elementAt(index),
                      onPressed: () {
                        if (currentUser.value.apiToken == null) {
                          Navigator.of(context).pushNamed('/Login');
                        } else {
                          if (_con.isSameMarkets(_con.products.elementAt(index))) {
                            _con.addToCart(_con.products.elementAt(index));
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // return object of type Dialog
                                return AddToCartAlertDialogWidget(
                                    oldProduct: _con.carts.elementAt(0)?.product,
                                    newProduct: _con.products.elementAt(index),
                                    onPressed: (product, {reset: true}) {
                                      return _con.addToCart(_con.products.elementAt(index), reset: true);
                                    });
                              },
                            );
                          }
                        }
                      });
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
