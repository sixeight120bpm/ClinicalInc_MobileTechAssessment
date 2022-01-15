	//
//  PlacesViewController.h
//  ClinicalInc_MobileTechAssessment
//
//  Created by user206074 on 1/15/22.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import CoreLocation;
@import GooglePlaces;
@import GoogleMaps;

#ifndef PlacesViewController_h
#define PlacesViewController_h

@interface PlacesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) NSMutableArray<GMSPlace *> * _Nullable likelyPlaces;
@property (weak, nonatomic) GMSPlace * _Nullable selectedPlace;
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
#endif /* PlacesViewController_h */
