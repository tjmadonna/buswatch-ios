# Bus Watch REST API

Bus Watch shows real-time transit information for the Pittsburgh Port Authority transit system. The app shows bus stops from a SQLite database in an MKMapView and retrieves bus arrival times from a [backend RESTful API](https://github.com/tjmadonna/buswatch-rest). The user can favorite stops and quickly access the arrival times for that stop from the main Overview screen.

## Technologies Used
* Swift
* [Combine](https://developer.apple.com/documentation/combine)
* [GRDB](https://github.com/groue/GRDB.swift)
* [GRDBCombine](https://github.com/groue/GRDBCombine)
* UIKit
* URLSession
* JSON Decodable
* Model-View-View Model

## Screenshots

<figure align="center">
  <img src="./Art/OverviewScreen.png" alt="Overview Screen" width="25%">
  <figcaption>Overview screen showing favorite stops and a map of stops</figcaption>
</figure>
<br>
<figure align="center">
  <img src="./Art/MapScreen.png" alt="Map Screen" width="25%">
  <figcaption>MKMapView of showing stops</figcaption>
</figure>
<br>
<figure align="center">
  <img src="./Art/PredictionsScreen.png" alt="Predictions Screen" width="25%">
  <figcaption>Predictions screen showing real-time bus arrival times</figcaption>
</figure>