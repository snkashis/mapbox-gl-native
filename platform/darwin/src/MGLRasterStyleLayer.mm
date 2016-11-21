// This file is generated. 
// Edit platform/darwin/scripts/generate-style-code.js, then run `make style-code-darwin`.

#import "MGLSource.h"
#import "MGLMapView_Private.h"
#import "NSPredicate+MGLAdditions.h"
#import "MGLStyleLayer_Private.h"
#import "MGLStyleValue_Private.h"
#import "MGLRasterStyleLayer.h"

#include <mbgl/style/layers/raster_layer.hpp>

@interface MGLRasterStyleLayer ()

@property (nonatomic) mbgl::style::RasterLayer *rawLayer;

@end

@implementation MGLRasterStyleLayer
{
    std::unique_ptr<mbgl::style::RasterLayer> _pendingLayer;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(MGLSource *)source
{
    if (self = [super initWithIdentifier:identifier source:source]) {
        auto layer = std::make_unique<mbgl::style::RasterLayer>(identifier.UTF8String, source.identifier.UTF8String);
        _pendingLayer = std::move(layer);
        self.rawLayer = _pendingLayer.get();
    }
    return self;
}



#pragma mark -  Adding to and removing from a map view

- (void)addToMapView:(MGLMapView *)mapView
{
    [self addToMapView:mapView belowLayer:nil];
}

- (void)addToMapView:(MGLMapView *)mapView belowLayer:(MGLStyleLayer *)otherLayer
{
    if (otherLayer) {
        const mbgl::optional<std::string> belowLayerId{otherLayer.identifier.UTF8String};
        mapView.mbglMap->addLayer(std::move(_pendingLayer), belowLayerId);
    } else {
        mapView.mbglMap->addLayer(std::move(_pendingLayer));
    }
}

- (void)removeFromMapView:(MGLMapView *)mapView
{
    auto removedLayer = mapView.mbglMap->removeLayer(self.identifier.UTF8String);
    _pendingLayer = std::move(reinterpret_cast<std::unique_ptr<mbgl::style::RasterLayer> &>(removedLayer));
    self.rawLayer = _pendingLayer.get();
}

#pragma mark - Accessing the Paint Attributes

- (void)setRasterOpacity:(MGLStyleValue<NSNumber *> *)rasterOpacity {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterOpacity);
    self.rawLayer->setRasterOpacity(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterOpacity {
    auto propertyValue = self.rawLayer->getRasterOpacity() ?: self.rawLayer->getDefaultRasterOpacity();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterHueRotate:(MGLStyleValue<NSNumber *> *)rasterHueRotate {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterHueRotate);
    self.rawLayer->setRasterHueRotate(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterHueRotate {
    auto propertyValue = self.rawLayer->getRasterHueRotate() ?: self.rawLayer->getDefaultRasterHueRotate();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterSaturation:(MGLStyleValue<NSNumber *> *)rasterSaturation {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterSaturation);
    self.rawLayer->setRasterSaturation(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterSaturation {
    auto propertyValue = self.rawLayer->getRasterSaturation() ?: self.rawLayer->getDefaultRasterSaturation();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterContrast:(MGLStyleValue<NSNumber *> *)rasterContrast {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterContrast);
    self.rawLayer->setRasterContrast(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterContrast {
    auto propertyValue = self.rawLayer->getRasterContrast() ?: self.rawLayer->getDefaultRasterContrast();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterFadeDuration:(MGLStyleValue<NSNumber *> *)rasterFadeDuration {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterFadeDuration);
    self.rawLayer->setRasterFadeDuration(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterFadeDuration {
    auto propertyValue = self.rawLayer->getRasterFadeDuration() ?: self.rawLayer->getDefaultRasterFadeDuration();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterBrightnessMinimum:(MGLStyleValue<NSNumber *> *)rasterBrightnessMinimum {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterBrightnessMinimum);
    self.rawLayer->setRasterBrightnessMinimum(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterBrightnessMinimum {
    auto propertyValue = self.rawLayer->getRasterBrightnessMinimum() ?: self.rawLayer->getDefaultRasterBrightnessMinimum();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setRasterBrightnessMaximum:(MGLStyleValue<NSNumber *> *)rasterBrightnessMaximum {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(rasterBrightnessMaximum);
    self.rawLayer->setRasterBrightnessMaximum(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)rasterBrightnessMaximum {
    auto propertyValue = self.rawLayer->getRasterBrightnessMaximum() ?: self.rawLayer->getDefaultRasterBrightnessMaximum();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}


@end
