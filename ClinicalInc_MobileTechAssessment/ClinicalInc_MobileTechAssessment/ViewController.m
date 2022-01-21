//
//  ViewController.m
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 12/27/21.
//

//Todo/post project thoughts:
//- this is NOT a single responsibility class and it should be.
//- Ideally, there would be seperate controllers for managing the map view, geocoding, location manager, and the search bar +search completer.
//  - Currently there is still more dependence between areas that I would like.
//  - Labels don't need to know about geocoding, geocoding doesn't need to know about the view. I'm relying on delegate actions to trigger changes instead of setting up my own events.
//- No tests. It's a very thin layer, I'm not doing anything with the data, no transformation, there's not really anything to test in terms of the model.
//  - API testing doesn't really falling in unit testing, since it relies on outside services.
//    - Maybe that's still wporth testing for documentation and to confirm I'm pulling the data I think I'm pulling?
//  - UITesting would be worthwhile and I could have benefitted from learning more about that.
//- No optonal requirements. I ran into time constraints and chose not to pursue those, but they would be worthwhile as a learning exercise.
#import "ViewController.h"
@import CoreLocation;
@import GoogleMaps;
@import MapKit;

@interface ViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet GMSMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *LocationCoordLabel;
@property (weak, nonatomic) IBOutlet UILabel *LocationNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *ZoomValue;
@property (weak, nonatomic) IBOutlet UISearchBar *AddressSearch;
@property (weak, nonatomic) IBOutlet UITableView *TableViewOutlet;
- (IBAction)ZoomValueChanged:(id)sender;

@end

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocation * _Nullable currentLocation;
    MKLocalSearchCompleter *searchCompleter;
    NSMutableArray *searchCompleterResults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLocationManager];
    [self configureMapView];
    [self configureSearchCompleter];
}

#pragma mark Label Management
-(void)updateLabelText:(CLLocationCoordinate2D)coordinates{
    [self.LocationCoordLabel setText: [self formatCoordinateString:coordinates]];
    [self getLocationAddressFromCoordinates:coordinates];
}

-(NSString*)formatCoordinateString:(CLLocationCoordinate2D)coordinates{
    return [NSString stringWithFormat:@"Current Location: (%@, %@)", [NSNumber numberWithFloat:coordinates.latitude], [NSNumber numberWithFloat:coordinates.longitude]];
}

#pragma mark Geocoding
-(void)getLocationAddressFromCoordinates:(CLLocationCoordinate2D)coordinates{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinates completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        for(GMSAddress* addressObj in [response results]){
            if (addressObj.thoroughfare != NULL) {
                [self.LocationNameLabel setText:[NSString stringWithFormat:@"%@, %@, %@, %@", addressObj.thoroughfare, addressObj.locality, addressObj.administrativeArea, addressObj.postalCode]];
                break;
            }
        }
    }];
}

-(void)getLocationCoordinatesFromAddress:(NSString *)address{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [self updateCamera:placemark.location.coordinate];
        }];
}

#pragma mark Map View management
-(void)configureMapView{
    self.MapView.delegate = self;
    self.MapView.settings.myLocationButton = YES;
    self.MapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.MapView.myLocationEnabled = YES;
}

-(void)updateCamera:(CLLocationCoordinate2D)coordinates{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinates.latitude longitude:coordinates.longitude zoom:self.ZoomValue.value];
    self.MapView.camera = camera;
    [self.MapView animateToCameraPosition:camera];
}

#pragma mark Map View Delegate
-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(nonnull GMSCameraPosition *)position{
    [self updateLabelText:position.target];
}

#pragma mark Locaton Manager
-(void)configureLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    locationManager.distanceFilter = 50;
    locationManager.delegate = self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.lastObject;
    [self updateCamera:location.coordinate];
    searchCompleter.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.5,0.5));
}

-(void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager
{
    switch (manager.accuracyAuthorization) {
        case CLAccuracyAuthorizationFullAccuracy:
            NSLog(@"Location accuracy is precise.");
            break;
        case CLAccuracyAuthorizationReducedAccuracy:
            NSLog(@"Location accuracy is not precise.");
            break;
    }
    
    switch (manager.authorizationStatus) {
      case kCLAuthorizationStatusRestricted:
        NSLog(@"Location access was restricted.");
        break;
      case kCLAuthorizationStatusDenied:
        NSLog(@"User denied access to location.");
            break;
      case kCLAuthorizationStatusNotDetermined:
        NSLog(@"Location status not determined.");
            break;
      case kCLAuthorizationStatusAuthorizedAlways:
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        NSLog(@"Location status is OK.");
            [locationManager startUpdatingLocation];
            break;
    }
}

// Handle location manager errors.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@", error.localizedDescription);
}

#pragma mark - Zoom slider action
- (IBAction)ZoomValueChanged:(id)sender {
    [self.MapView animateToZoom:self.ZoomValue.value];
}

#pragma mark - Search Bar Delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self getLocationCoordinatesFromAddress:searchBar.text];
    [searchBar resignFirstResponder];
    self.TableViewOutlet.hidden = YES;
    [self.AddressSearch setText:@""];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchCompleter.queryFragment = searchText;
}

#pragma mark Search Completer
-(void)configureSearchCompleter{
    searchCompleter = [[MKLocalSearchCompleter alloc]init];
    searchCompleter.delegate = self;
    searchCompleterResults = [[NSMutableArray alloc]init];
}

-(void)completerDidUpdateResults:(MKLocalSearchCompleter *)completer{
    NSLog(@"%@", completer.results);
    
    [searchCompleterResults removeAllObjects];
    for (MKLocalSearchCompletion *result in searchCompleter.results) {
        [searchCompleterResults addObject:result.title];
    }
    
    [self.TableViewOutlet reloadData];
    if (self.TableViewOutlet.isHidden) {
        self.TableViewOutlet.hidden = NO;
    }
}

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [searchCompleterResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellId = @"SimpleTableId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell.textLabel setText:[searchCompleterResults objectAtIndex:indexPath.row]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section{
    return @"Results";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
(NSInteger)section{
    return @"";
}

#pragma mark - TableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self getLocationCoordinatesFromAddress:cell.textLabel.text];
    [self.AddressSearch resignFirstResponder];
    self.TableViewOutlet.hidden = YES;
    [self.AddressSearch setText:@""];
}

@end
