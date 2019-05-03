# Weather

This app has been a running project for me to practice various elements of iOS programming as I have learned them.
Among other things, this has solidified my understanding of Core Location, URLSession, parsing JSON data and restructuring it
into a form that makes sense for my app, UIAlertControllers, passing information between view controllers using delegate protocols
and unwind segues, persisting data, and configuring table views.

There are a lot of improvements that could be made. The UI for adding cities is pretty basic and could be a lot more attractive.
The process of adding cities requires the user to manually enter values for latitude and longitude, which is far from ideal. A
better solution would be to search an existing database of city names mapped to coordinates that could be updated as the user
types using prefix matching. Another idea would be to use a MKMapView to allow the user to pick a location on a map. All three
input methods (lat/lon, city name search, map) could potentially be used nested inside a TabBarController.
