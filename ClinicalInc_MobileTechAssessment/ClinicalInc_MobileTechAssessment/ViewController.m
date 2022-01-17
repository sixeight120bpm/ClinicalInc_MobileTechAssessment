//
//  ViewController.m
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

#import "ViewController.h"
#import "PlacesViewController.h"
@import CoreLocation;
@import GooglePlaces;
@import GoogleMaps;

@interface ViewController () <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *LocationCoordLabel;
@property (weak, nonatomic) IBOutlet UILabel *LocationNameLabel;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocation * _Nullable currentLocation;
    GMSPlacesClient *placesClient;
    float preciseLocationZoomLevel;
    float approximateLocationZoomLevel;
    
    // An array to hold the list of likely places.
    NSMutableArray<GMSPlace *> *likelyPlaces;

    // The currently selected place.
    GMSPlace * _Nullable selectedPlace;
  }

  - (void)viewDidLoad {
    [super viewDidLoad];


    preciseLocationZoomLevel = 15.0;
    approximateLocationZoomLevel = 15.0;

    // Initialize the location manager.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
    locationManager.delegate = self;

    placesClient = [GMSPlacesClient sharedClient];

    // A default location to use when location permission is not granted.
    CLLocationCoordinate2D defaultLocation = CLLocationCoordinate2DMake(-33.869405, 151.199);
    
    // Create a map.
    float zoomLevel = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:defaultLocation.latitude
                                                            longitude:defaultLocation.longitude
                                                                 zoom:zoomLevel];
      

      for (UIView *view in self.view.subviews) {
          if ([view.accessibilityLabel isEqualToString:@"MapViewView"]) {
              self.MapView = [GMSMapView mapWithFrame:view.bounds camera:camera];
              break;
          }
      }

      
      self.MapView.settings.myLocationButton = YES;
      self.MapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      self.MapView.myLocationEnabled = YES;

    // Add the map to the view, hide it until we've got a location update.
    [self.view addSubview:self.MapView];
      
      self.MapView.hidden = YES;

    [self listLikelyPlaces];
  }

  // Populate the array with the list of likely places.
  - (void) listLikelyPlaces
  {
    // Clean up from previous sessions.
    likelyPlaces = [NSMutableArray array];

    GMSPlaceField placeFields = GMSPlaceFieldName | GMSPlaceFieldCoordinate;
    [placesClient findPlaceLikelihoodsFromCurrentLocationWithPlaceFields:placeFields callback:^(NSArray<GMSPlaceLikelihood *> * _Nullable likelihoods, NSError * _Nullable error) {
      if (error != nil) {
        // TODO: Handle the error.
        NSLog(@"Current Place error: %@", error.localizedDescription);
        return;
      }
      
      if (likelihoods == nil) {
        NSLog(@"No places found.");
        return;
      }
      
      for (GMSPlaceLikelihood *likelihood in likelihoods) {
        GMSPlace *place = likelihood.place;
          [self->likelyPlaces addObject:place];
      }
        if (self->selectedPlace == nil) {
            self->selectedPlace = self->likelyPlaces.firstObject;
            NSLog(@"%@", self->selectedPlace);
            [self.LocationNameLabel setText:self->selectedPlace.name];
        }
    }];
  }

  // Update the map once the user has made their selection.
  - (void) unwindToMain:(UIStoryboardSegue *)segue
  {
    // Clear the map.
    [self.MapView clear];

    // Add a marker to the map.
    if (selectedPlace != nil) {
      GMSMarker *marker = [GMSMarker markerWithPosition:selectedPlace.coordinate];
      marker.title = selectedPlace.name;
      marker.snippet = selectedPlace.formattedAddress;
      marker.map = self.MapView;
        [self.LocationNameLabel setText:selectedPlace.name];
        [self.LocationCoordLabel setText:[NSString stringWithFormat:@"Current Location: (%@, %@)", [NSNumber numberWithFloat:marker.position.latitude], [NSNumber numberWithFloat:marker.position.longitude]]];
    }

    [self listLikelyPlaces];
  }

  // Prepare the segue.
  - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
    if ([segue.identifier isEqualToString:@"segueToSelect"]) {
      if ([segue.destinationViewController isKindOfClass:[PlacesViewController class]]) {
        PlacesViewController *placesViewController = (PlacesViewController *)segue.destinationViewController;
        placesViewController.likelyPlaces = likelyPlaces;
      }
    }
  }

  // Delegates to handle events for the location manager.
  #pragma mark - CLLocationManagerDelegate

  // Handle incoming location events.
  - (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
  {
    CLLocation *location = locations.lastObject;
    NSLog(@"Location: %@", location);
    
    float zoomLevel = locationManager.accuracyAuthorization == CLAccuracyAuthorizationFullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel;
    GMSCameraPosition * camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude
                                                             longitude:location.coordinate.longitude
                                                                  zoom:zoomLevel];

      [self.LocationCoordLabel setText:[NSString stringWithFormat:@"Current Location: (%@, %@)", [NSNumber numberWithFloat:location.coordinate.latitude], [NSNumber numberWithFloat:location.coordinate.longitude]]];
      
     
      
    if (self.MapView.isHidden) {
        self.MapView.hidden = NO;
        self.MapView.camera = camera;
    } else {
      [self.MapView animateToCameraPosition:camera];
    }

      [self listLikelyPlaces];
  }

  // Handle authorization for the location manager.
  - (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
  {
    // Check accuracy authorization
    CLAccuracyAuthorization accuracy = manager.accuracyAuthorization;
    switch (accuracy) {
      case CLAccuracyAuthorizationFullAccuracy:
        NSLog(@"Location accuracy is precise.");
        break;
      case CLAccuracyAuthorizationReducedAccuracy:
        NSLog(@"Location accuracy is not precise.");
        break;
    }
    
    // Handle authorization status
    switch (status) {
      case kCLAuthorizationStatusRestricted:
        NSLog(@"Location access was restricted.");
        break;
      case kCLAuthorizationStatusDenied:
        NSLog(@"User denied access to location.");
        // Display the map using the default location.
            self.MapView.hidden = NO;
      case kCLAuthorizationStatusNotDetermined:
        NSLog(@"Location status not determined.");
      case kCLAuthorizationStatusAuthorizedAlways:
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        NSLog(@"Location status is OK.");
    }
  }

  // Handle location manager errors.
  - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
  {
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@", error.localizedDescription);
  }

  @end
