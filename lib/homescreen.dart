import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position _currentPosition;
  String _currentAddress;
  bool isLoading = false;

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};

  BitmapDescriptor pinmarker;

  @override
  void initState() {
    markerCustom();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        isLoading = true;
        print(" CP : $_currentPosition");
      });
    }).catchError((e) {
      print("Error : $e");
    });
    super.initState();
  }

  void markerCustom() async {
    pinmarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId("1"),
          position:
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
          icon: pinmarker,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location"),
        backgroundColor: Colors.red,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          isLoading
              ? GoogleMap(
                  mapType: MapType.satellite,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                    zoom: 11.0,
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
          isLoading
              ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200.0,
                  margin: EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Wrap(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              if (_currentAddress != null)
                                Text(
                                  _currentAddress,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              else
                                Text("No Location Found"),
                              SizedBox(
                                height: 30.0,
                              ),
                              if (_currentPosition != null)
                                Text(
                                  "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              else
                                Text("No Location Found"),
                              SizedBox(
                                height: 30.0,
                              ),
                              // ignore: deprecated_member_use
                              FlatButton(
                                child: Text(
                                  "Get location",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                color: Colors.redAccent,
                                onPressed: () {
                                  // Get location here
                                  _getCurrentPosition();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _getCurrentPosition() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        isLoading = true;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      Placemark placemark = placemarks[0];

      setState(() {
        _currentAddress =
            "${placemark.street},${placemark.locality},${placemark.subLocality}, ${placemark.postalCode},${placemark.administrativeArea},${placemark.country}";
      });
    } catch (e) {}
  }
}
