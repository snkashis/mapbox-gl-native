// This file is generated. 
// Edit platform/darwin/scripts/generate-style-code.js, then run `make style-code-darwin`.

#import "MGLSource.h"
#import "MGLMapView_Private.h"
#import "NSPredicate+MGLAdditions.h"
#import "MGLStyleLayer_Private.h"
#import "MGLStyleValue_Private.h"
#import "MGLCircleStyleLayer.h"

#include <mbgl/style/layers/circle_layer.hpp>

namespace mbgl {

    using namespace style;


    MBGL_DEFINE_ENUM(MGLCircleTranslateAnchor, {
        { MGLCircleTranslateAnchorMap, "map" },
        { MGLCircleTranslateAnchorViewport, "viewport" },
    });
    MBGL_DEFINE_ENUM(MGLCirclePitchScale, {
        { MGLCirclePitchScaleMap, "map" },
        { MGLCirclePitchScaleViewport, "viewport" },
    });
}

@interface MGLCircleStyleLayer ()

@property (nonatomic) mbgl::style::CircleLayer *rawLayer;

@end

@implementation MGLCircleStyleLayer
{
    std::unique_ptr<mbgl::style::CircleLayer> _pendingLayer;
}

- (instancetype)initWithIdentifier:(NSString *)identifier source:(MGLSource *)source
{
    if (self = [super initWithIdentifier:identifier source:source]) {
        auto layer = std::make_unique<mbgl::style::CircleLayer>(identifier.UTF8String, source.identifier.UTF8String);
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
    _pendingLayer = std::move(reinterpret_cast<std::unique_ptr<mbgl::style::CircleLayer> &>(removedLayer));
    _rawLayer = _pendingLayer.get();
}

#pragma mark - Accessing the Paint Attributes

- (void)setCircleRadius:(MGLStyleValue<NSNumber *> *)circleRadius {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(circleRadius);
    _rawLayer->setCircleRadius(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)circleRadius {
    auto propertyValue = _rawLayer->getCircleRadius() ?: _rawLayer->getDefaultCircleRadius();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setCircleColor:(MGLStyleValue<MGLColor *> *)circleColor {
    auto mbglValue = MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toPropertyValue(circleColor);
    _rawLayer->setCircleColor(mbglValue);
}

- (MGLStyleValue<MGLColor *> *)circleColor {
    auto propertyValue = _rawLayer->getCircleColor() ?: _rawLayer->getDefaultCircleColor();
    return MGLStyleValueTransformer<mbgl::Color, MGLColor *>().toStyleValue(propertyValue);
}

- (void)setCircleBlur:(MGLStyleValue<NSNumber *> *)circleBlur {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(circleBlur);
    _rawLayer->setCircleBlur(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)circleBlur {
    auto propertyValue = _rawLayer->getCircleBlur() ?: _rawLayer->getDefaultCircleBlur();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setCircleOpacity:(MGLStyleValue<NSNumber *> *)circleOpacity {
    auto mbglValue = MGLStyleValueTransformer<float, NSNumber *>().toPropertyValue(circleOpacity);
    _rawLayer->setCircleOpacity(mbglValue);
}

- (MGLStyleValue<NSNumber *> *)circleOpacity {
    auto propertyValue = _rawLayer->getCircleOpacity() ?: _rawLayer->getDefaultCircleOpacity();
    return MGLStyleValueTransformer<float, NSNumber *>().toStyleValue(propertyValue);
}

- (void)setCircleTranslate:(MGLStyleValue<NSValue *> *)circleTranslate {
    auto mbglValue = MGLStyleValueTransformer<std::array<float, 2>, NSValue *>().toPropertyValue(circleTranslate);
    _rawLayer->setCircleTranslate(mbglValue);
}

- (MGLStyleValue<NSValue *> *)circleTranslate {
    auto propertyValue = _rawLayer->getCircleTranslate() ?: _rawLayer->getDefaultCircleTranslate();
    return MGLStyleValueTransformer<std::array<float, 2>, NSValue *>().toStyleValue(propertyValue);
}

- (void)setCircleTranslateAnchor:(MGLStyleValue<NSValue *> *)circleTranslateAnchor {
    if ([circleTranslateAnchor isKindOfClass:[MGLStyleFunction class]]) {
        MGLStyleFunction<NSValue *> *function = (MGLStyleFunction<NSValue *> *)circleTranslateAnchor;
        __block std::vector<std::pair<float, mbgl::style::TranslateAnchorType>> mbglStops;
        [function.stops enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull zoomKey, MGLStyleValue<NSValue *> * _Nonnull stopValue, BOOL * _Nonnull stop) {
            id value = [(MGLStyleConstantValue<NSValue *> *)stopValue rawValue];
            MGLCircleTranslateAnchor circleTranslateAnchorValue;
            [value getValue:&circleTranslateAnchorValue];
            auto str = mbgl::Enum<MGLCircleTranslateAnchor>::toString(circleTranslateAnchorValue);
            auto mbglValue = mbgl::Enum<mbgl::style::TranslateAnchorType>::toEnum(str).value_or(_rawLayer->getDefaultCircleTranslateAnchor().asConstant());
            auto mbglStopValue = mbgl::style::PropertyValue<mbgl::style::TranslateAnchorType>(mbglValue);
            mbglStops.emplace_back(zoomKey.floatValue, mbglStopValue.asConstant());
        }];
        auto func = mbgl::style::Function<mbgl::style::TranslateAnchorType>({{mbglStops}}, function.base);
        _rawLayer->setCircleTranslateAnchor(func);
        return;
    }
    id value = [(MGLStyleConstantValue<NSValue *> *)circleTranslateAnchor rawValue];
    MGLCircleTranslateAnchor circleTranslateAnchorValue;
    [value getValue:&circleTranslateAnchorValue];
    auto str = mbgl::Enum<MGLCircleTranslateAnchor>::toString(circleTranslateAnchorValue);
    auto mbglValue = mbgl::Enum<mbgl::style::TranslateAnchorType>::toEnum(str).value_or(_rawLayer->getDefaultCircleTranslateAnchor().asConstant());
    _rawLayer->setCircleTranslateAnchor(mbglValue);
}

- (MGLStyleValue<NSValue *> *)circleTranslateAnchor {
    auto propertyValue = _rawLayer->getCircleTranslateAnchor() ?: _rawLayer->getDefaultCircleTranslateAnchor();
    
    return MGLStyleEnumerationValueTransformer<mbgl::style::TranslateAnchorType, MGLCircleTranslateAnchor>().propertyValueMGLStyleValue(propertyValue);
}

- (void)setCirclePitchScale:(MGLStyleValue<NSValue *> *)circlePitchScale {
    if ([circlePitchScale isKindOfClass:[MGLStyleFunction class]]) {
        MGLStyleFunction<NSValue *> *function = (MGLStyleFunction<NSValue *> *)circlePitchScale;
        __block std::vector<std::pair<float, mbgl::style::CirclePitchScaleType>> mbglStops;
        [function.stops enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull zoomKey, MGLStyleValue<NSValue *> * _Nonnull stopValue, BOOL * _Nonnull stop) {
            id value = [(MGLStyleConstantValue<NSValue *> *)stopValue rawValue];
            MGLCirclePitchScale circlePitchScaleValue;
            [value getValue:&circlePitchScaleValue];
            auto str = mbgl::Enum<MGLCirclePitchScale>::toString(circlePitchScaleValue);
            auto mbglValue = mbgl::Enum<mbgl::style::CirclePitchScaleType>::toEnum(str).value_or(_rawLayer->getDefaultCirclePitchScale().asConstant());
            auto mbglStopValue = mbgl::style::PropertyValue<mbgl::style::CirclePitchScaleType>(mbglValue);
            mbglStops.emplace_back(zoomKey.floatValue, mbglStopValue.asConstant());
        }];
        auto func = mbgl::style::Function<mbgl::style::CirclePitchScaleType>({{mbglStops}}, function.base);
        _rawLayer->setCirclePitchScale(func);
        return;
    }
    id value = [(MGLStyleConstantValue<NSValue *> *)circlePitchScale rawValue];
    MGLCirclePitchScale circlePitchScaleValue;
    [value getValue:&circlePitchScaleValue];
    auto str = mbgl::Enum<MGLCirclePitchScale>::toString(circlePitchScaleValue);
    auto mbglValue = mbgl::Enum<mbgl::style::CirclePitchScaleType>::toEnum(str).value_or(_rawLayer->getDefaultCirclePitchScale().asConstant());
    _rawLayer->setCirclePitchScale(mbglValue);
}

- (MGLStyleValue<NSValue *> *)circlePitchScale {
    auto propertyValue = _rawLayer->getCirclePitchScale() ?: _rawLayer->getDefaultCirclePitchScale();
    
    return MGLStyleEnumerationValueTransformer<mbgl::style::CirclePitchScaleType, MGLCirclePitchScale>().propertyValueMGLStyleValue(propertyValue);
}


@end
