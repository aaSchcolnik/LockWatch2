//
// NWCConditionsTemplateFormatter+LWAdditions.m
// LockWatch [SSH: janiks-mac-mini.local]
//
// Created by janikschmidt on 7/2/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import <ClockKit/CLKComplicationTemplateModularSmallSimpleText.h>
#import <ClockKit/CLKSimpleTextProvider.h>
#import <NanoWeatherComplicationsCompanion/NWCColor.h>
#import <NanoWeatherComplicationsCompanion/NWCFiveHourForecastView.h>
#import <WeatherFoundation/WFLocation.h>
#import <WeatherFoundation/WFWeatherConditions.h>

#import "NWCConditionsTemplateFormatter+LWAdditions.h"

#if __cplusplus
extern "C" {
#endif

NSString* NWCLocalizedString(NSString* key, NSString* comment);
NSArray* NWCPlaceholderHourlyConditionsStartingAtDate(NSDate* date, int count);

#if __cplusplus
}
#endif

@implementation NWCConditionsTemplateFormatter (LWAdditions)

- (void)_circularMediumTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self circularMediumTemplateForConditions:conditions]);
	}
}

- (void)_circularSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self circularSmallTemplateForConditions:conditions]);
	}
}

- (void)_extraLargeTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self extraLargeTemplateForConditions:conditions]);
	}
}

- (void)_graphicBezelTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions dailyForecastedConditions:(WFWeatherConditions*)dayForecast templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplateModularSmallSimpleText* template = [self graphicBezelTemplateForConditions:conditions dailyForecastedConditions:dayForecast];
	
	if (!conditions || isLoading) {
		[template setTextProvider:[CLKSimpleTextProvider textProviderWithText:NWCLocalizedString(@"LOADING_LONG", @"Loading Weather Data")]];
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}

- (void)_graphicCircularTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self graphicCircularTemplateForConditions:conditions]);
	}
}

- (void)_graphicCornerTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self graphicCornerTemplateForConditions:conditions]);
	}
}

- (void)_graphicRectangularTemplateForEntryDate:(NSDate*)entryDate
								 isLocalLocation:(BOOL)isLocalLocation
								      conditions:(WFWeatherConditions*)conditions
					   dailyForecastedConditions:(WFWeatherConditions*)dayForecast
					  hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
								        timeZone:(NSTimeZone*)timeZone
								       isLoading:(BOOL)isLoading
								   templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	CLKComplicationTemplate* template;
	
	if (!conditions || hourlyForecasts.count < NWCFiveHourForecastView.maximumHourlyConditionCount) {
		NSString* text = NWCLocalizedString(isLoading ? @"LOADING_LONG" : @"WEATHER", @"Weather / Loading Weather Data");
		
		CLKSimpleTextProvider* textProvider = [CLKSimpleTextProvider textProviderWithText:[text localizedUppercaseString]];
		[textProvider setTintColor:NWCColor.titleNoDataColor];
		
		template = [self _graphicRectangularTemplateWithTextProvider:textProvider hourlyForecastedConditions:NWCPlaceholderHourlyConditionsStartingAtDate(entryDate, NWCFiveHourForecastView.maximumHourlyConditionCount) timeZone:timeZone];
	} else {
		NSMutableArray* hourlyConditions = [NSMutableArray arrayWithCapacity:NWCFiveHourForecastView.maximumHourlyConditionCount];
		
		[hourlyForecasts enumerateObjectsUsingBlock:^(WFWeatherConditions* forecast, NSUInteger index, BOOL* stop) {
			[hourlyConditions addObject:forecast];
			*stop = hourlyConditions.count >= NWCFiveHourForecastView.maximumHourlyConditionCount;
		}];
		
		NSDate* _currentConditionsDate = [(NSDateComponents*)[conditions objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		NSDate* _forecastDate = [(NSDateComponents*)[hourlyForecasts[0] objectForKeyedSubscript:@"WFWeatherForecastTimeComponent"] date];
		
		if ([_forecastDate compare:_currentConditionsDate] == NSOrderedAscending) {
			[hourlyConditions replaceObjectAtIndex:0 withObject:conditions];
		} else {
			hourlyConditions = [[@[conditions] arrayByAddingObjectsFromArray:[hourlyConditions subarrayWithRange:NSMakeRange(0, 4)]] mutableCopy];
		}
		
		template = [self graphicRectangularTemplateForLocalLocation:isLocalLocation timeZone:timeZone conditions:conditions dailyForecastedConditions:dayForecast hourlyForecastedConditions:hourlyConditions];
	}
	
	if (templateBlock) {
		templateBlock(template);
	}
}

- (void)_modularSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self modularSmallTemplateForConditions:conditions]);
	}
}

- (void)_utilitarianSmallTemplateForEntryDate:(NSDate*)entryDate isLoading:(BOOL)isLoading conditions:(WFWeatherConditions*)conditions templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	if (templateBlock) {
		templateBlock([self utilitarianSmallTemplateForConditions:conditions]);
	}
}

- (void)formattedTemplateForFamily:(NTKComplicationFamily)family
                    	 entryDate:(NSDate*)entryDate
						 isLoading:(BOOL)isLoading
					withConditions:(WFWeatherConditions*)conditions
		 dailyForecastedConditions:(NSArray<WFWeatherConditions*>*)dayForecasts
	    hourlyForecastedConditions:(NSArray<WFWeatherConditions*>*)hourlyForecasts
						  location:(WFLocation*)location
				   isLocalLocation:(BOOL)isLocalLocation
					 templateBlock:(void (^)(CLKComplicationTemplate* template))templateBlock {
	switch (family) {
		case NTKComplicationFamilyModularSmall:
			[self _modularSmallTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyUtilitarianSmall:
		case NTKComplicationFamilyUtilitarianSmallFlat:
			[self _utilitarianSmallTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyCircularSmall:
			[self _circularSmallTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyExtraLarge:
			[self _extraLargeTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyGraphicCorner:
			[self _graphicCornerTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyGraphicBezel:
			[self _graphicBezelTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions dailyForecastedConditions:dayForecasts[0] templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyGraphicCircular:
			[self _graphicCircularTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyGraphicRectangular:
			[self _graphicRectangularTemplateForEntryDate:entryDate isLocalLocation:isLocalLocation conditions:conditions dailyForecastedConditions:dayForecasts[0] hourlyForecastedConditions:hourlyForecasts timeZone:location.timeZone isLoading:isLoading templateBlock:templateBlock];
			break;
		case NTKComplicationFamilyCircularMedium:
			[self _circularMediumTemplateForEntryDate:entryDate isLoading:isLoading conditions:conditions templateBlock:templateBlock];
			break;
		default: break;
	}
}

@end