// This file is generated. 
// Edit platform/darwin/scripts/generate-style-code.js, then run `make style-code-darwin`.

#import "MGLSource.h"
#import "MGLMapView_Private.h"
#import "NSPredicate+MGLAdditions.h"
#import "MGLStyleLayer_Private.h"
#import "MGLStyleValue_Private.h"
#import "MGLFillStyleLayer.h"

#include <mbgl/style/layers/fill_layer.hpp>

namespace mbgl {

    using namespace style;


    MBGL_DEFINE_ENUM(MGLFillTranslateAnchor, {
        { MGLFillTranslateAnchorMap, "map" },
        { MGLFillTranslateAnchorViewport, "viewport" },
    });
}

@interface MGLFillStyleLayer ()

@property (nonatomic) mbgl::style::FillLayer *rawLayer;

@end

@implementation MGLFillStyleLayer
{
    std::unique_ptr<mbgl::style::FillLayer> _pendingLayer;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(MGLSource *)source
{
    if (self = [super initWithIdentifier:identifier source:source]) {
        auto layer = std::make_unique<mbgl::style::FillLayer>(identifier.UTF8String, source.identifier.UTF8String);
        _pendingLayer = std::move(layer);
        _rawLayer = _pendingLayer.get();
    }
    return self;
}


- (NSString *)sourceLayerIdentifier
{
    auto layerID = _rawLayer->getSourceLayer();
    return layerID.empty() ? nil : @(layerID.c_str());
}

- (void)setSourceLayerIdentifier:(NSString *)sourceLayerIdentifier
{
    _rawLayer->setSourceLayer(sourceLayerIdentifier.UTF8String ?: "");
}

- (void)setPredicate:(NSPredicate *)predicate
{
    _rawLayer->setFilter(predicate.mgl_filter);
}

- (NSPredicate *)predicate
{
    return [NSPredicate mgl_predicateWithFilter:_rawLayer->getFilter()];
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
    _pendingLayer = std::move(reinterpret_cast<std::unique_ptr<mbgl::style::FillLayer> &>(removedLayer));
    _rawLayer = _pendingLayer.get();
}

#pragma mark - Accessing the Paint Attributes

- (void)setFillAntialias:(MGLStyleValue<NSNumber *> *)fillAntialias {
    auto mbglValue = MGLStyleValueTransformer<bool, NSNumber *>().toPropertyValue(fillAntialias);
    _rawLayer->setFillAntialias(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)fillAntialias {
    auto propertyValue = _rawLayer->getFillAntialias() ?: _rawLayer->getDefaultFillAntialias();
    return MGLStyleValueTransformer<bool, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setFillOpacity:(MGLStyleValue<NSNumber *> *)fillOpacity {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(fillOpacity);
    _rawLayer->setFillOpacity(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)fillOpacity {
    auto propertyValue = _rawLayer->getFillOpacity() ?: _rawLayer->getDefaultFillOpacity();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setFillColor:(MGLStyleValue<MGLColor *> *)fillColor {
    auto mbglValue = MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toPropertyValue(fillColor);
    _rawLayer->setFillColor(mbglValue);
}

- (MGLStyleValue<MGLColor *> *)fillColor {
    auto propertyValue = _rawLayer->getFillColor() ?: _rawLayer->getDefaultFillColor();
    return MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toStyleValue(propertyValue);
}

- (void)setFillOutlineColor:(MGLStyleValue<MGLColor *> *)fillOutlineColor {
    auto mbglValue = MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toPropertyValue(fillOutlineColor);
    _rawLayer->setFillOutlineColor(mbglValue);
}

- (MGLStyleValue<MGLColor *> *)fillOutlineColor {
    auto propertyValue = _rawLayer->getFillOutlineColor() ?: _rawLayer->getDefaultFillOutlineColor();
    return MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toStyleValue(propertyValue);
}

- (void)setFillTranslate:(MGLStyleValue<NSValue *> *)fillTranslate {
    auto mbglValue = MGLStyleValueTransformer<std::array<float, 2>, NSValue *>().toPropertyValue(fillTranslate);
    _rawLayer->setFillTranslate(mbglValue);
}

- (MGLStyleValue<NSValue *> *)fillTranslate {
    auto propertyValue = _rawLayer->getFillTranslate() ?: _rawLayer->getDefaultFillTranslate();
    return MGLStyleValueTransformer<std::array<float, 2>, NSValue *>().toStyleValue(propertyValue);
}

- (void)setFillTranslateAnchor:(MGLStyleValue<NSValue *> *)fillTranslateAnchor {
    if ([fillTranslateAnchor isKindOfClass:[MGLStyleFunction class]]) {
        MGLStyleFunction<NSValue *> *function = (MGLStyleFunction<NSValue *> *)fillTranslateAnchor;
        __block std::vector<std::pair<float, mbgl::style::TranslateAnchorType>> mbglStops;
        [function.stops enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull zoomKey, MGLStyleValue<NSValue *> * _Nonnull stopValue, BOOL * _Nonnull stop) {
            id value = [(MGLStyleConstantValue<NSValue *> *)stopValue rawValue];
            MGLFillTranslateAnchor fillTranslateAnchorValue;
            [value getValue:&fillTranslateAnchorValue];
            auto str = mbgl::Enum<MGLFillTranslateAnchor>::toString(fillTranslateAnchorValue);
            auto mbglValue = mbgl::Enum<mbgl::style::TranslateAnchorType>::toEnum(str).value_or(_rawLayer->getDefaultFillTranslateAnchor().asConstant());
            auto mbglStopValue = mbgl::style::PropertyValue<mbgl::style::TranslateAnchorType>(mbglValue);
            mbglStops.emplace_back(zoomKey.floatValue, mbglStopValue.asConstant());
        }];
        auto func = mbgl::style::Function<mbgl::style::TranslateAnchorType>({{mbglStops}}, function.base);
        _rawLayer->setFillTranslateAnchor(func);
        return;
    }
    id value = [(MGLStyleConstantValue<NSValue *> *)fillTranslateAnchor rawValue];
    MGLFillTranslateAnchor fillTranslateAnchorValue;
    [value getValue:&fillTranslateAnchorValue];
    auto str = mbgl::Enum<MGLFillTranslateAnchor>::toString(fillTranslateAnchorValue);
    auto mbglValue = mbgl::Enum<mbgl::style::TranslateAnchorType>::toEnum(str).value_or(_rawLayer->getDefaultFillTranslateAnchor().asConstant());
    _rawLayer->setFillTranslateAnchor(mbglValue);
}

- (MGLStyleValue<NSValue *> *)fillTranslateAnchor {
    auto propertyValue = _rawLayer->getFillTranslateAnchor() ?: _rawLayer->getDefaultFillTranslateAnchor();
    
    return MGLStyleEnumerationValueTransformer<mbgl::style::TranslateAnchorType, MGLFillTranslateAnchor>().propertyValueMGLStyleValue(propertyValue);
}

- (void)setFillPattern:(MGLStyleValue<NSString *> *)fillPattern {
    auto mbglValue = MGLStyleValueTransformer<std::string, NSString *>().toPropertyValue(fillPattern);
    _rawLayer->setFillPattern(mbglValue);
}

- (MGLStyleValue<NSString *> *)fillPattern {
    auto propertyValue = _rawLayer->getFillPattern() ?: _rawLayer->getDefaultFillPattern();
    return MGLStyleValueTransformer<std::string, NSString *>().toStyleValue(propertyValue);
}


@end
