//
//  MKMapView+ASCategory.m
//  PhoneOnline
//
//  Created by Kowloon on 12-8-14.
//  Copyright (c) 2012年 Goome. All rights reserved.
//

#import "MKMapView+ASCategory.h"

//static CLLocationDegrees const kMinimumLatitude = - 90;
static CLLocationDegrees const kMaximumLatitude = 90;
//static CLLocationDegrees const kMinimumLongitude = - 180;
static CLLocationDegrees const kMaximumLongitude = 180;

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@implementation MKMapView (ASCategory)

#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

- (int)zoomLevel{
    return 20 - round(log2(self.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * self.bounds.size.width)));
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView centerCoordinate:(CLLocationCoordinate2D)centerCoordinate andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setZoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated
{
    MKCoordinateRegion theRegion = self.region;
    
    // Zoom out
    theRegion.span.longitudeDelta /= zoomLevel;
    theRegion.span.latitudeDelta /= zoomLevel;
    [self setVerificationRegion:theRegion animated:YES];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate zoomLevel:(NSUInteger)zoomLevel animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MIN(zoomLevel, 28);
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setVerificationRegion:region animated:animated];
}

- (void)removeAllAnnotations
{
    [self removeAnnotations:self.annotations];
}

- (void)reloadData
{
    NSArray *annotations = [self.annotations copy];
    [self removeAllAnnotations];
    [self addAnnotations:annotations];
}

- (void)reloadAnnotationViewWithAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation) {
        [self removeAnnotation:annotation];
        [self addAnnotation:annotation];
    }
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated invalidCoordinateHandler:(void (^)(void))handler
{
    if (fabs(coordinate.latitude) > kMaximumLatitude || fabs(coordinate.longitude) > kMaximumLongitude) {
//        ASLog(@"Invalid coordinate:%@",NSStringFromCLLocationCoordinate2D(coordinate));
        if (handler) {
            handler();
        }
    } else {
        [self setCenterCoordinate:coordinate animated:animated];
    }
}

- (void)setRegion:(MKCoordinateRegion)region animated:(BOOL)animated invalidCoordinateHandler:(void (^)(void))handler
{
    if (fabs(region.center.latitude) > kMaximumLatitude || fabs(region.center.longitude) > kMaximumLongitude) {
//        ASLog(@"Invalid coordinate:%@",NSStringFromCLLocationCoordinate2D(region.center));
        if (handler) {
            handler();
        }
    } else {
        MKCoordinateRegion fitRegion = [self regionThatFits:region];
        if (isnan(fitRegion.center.latitude)) {
            // iOS 6 will result in nan.
            fitRegion.center.latitude = region.center.latitude;
            fitRegion.center.longitude = region.center.longitude;
            fitRegion.span.latitudeDelta = 0;
            fitRegion.span.longitudeDelta = 0;
        }
        [self setRegion:fitRegion animated:animated];
    }
}

- (void)setVerificationRegion:(MKCoordinateRegion)region animated:(BOOL)animated
{
    if (fabs(region.center.latitude) > kMaximumLatitude
        || fabs(region.center.longitude) > kMaximumLongitude
        || (region.center.latitude == 0 && region.center.longitude == 0)
        || fabs(region.span.latitudeDelta) > kMaximumLongitude
        || fabs(region.span.longitudeDelta) > kMaximumLongitude) {
        return;
    }

    [self setRegion:region animated:animated];
}

@end
