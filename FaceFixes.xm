//
// FaceFixes.xm
// LockWatch2
//
// Created by janikschmidt on 1/23/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FaceFixes.h"

%group SpringBoard
%hook CLKDate
+ (id)unmodifiedDate {
	return [NSDate date];
}
+ (id)date {
	return [NSDate date];
}
+ (id)complicationDate {
	return [NSDate date];
}
%end	/// %hook CLKDate

%hook NTKDate
+ (id)faceDate {
	return [NSDate date];
}
%end	/// %hook NTKDate



%hook ARUIRingsView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook ARUIRingsView

%hook CALayer
%new
- (BOOL)hasSuperviewOfClass:(Class)_class {
	UIView* view = (UIView*)self.delegate;
	
	while (view) {
		if ([view isKindOfClass:_class]) {
			return YES;
		}
		
		view = view.superview;
	}
	
	return NO;
}

- (BOOL)allowsEdgeAntialiasing {
	if ([self hasSuperviewOfClass:%c(NTKFaceView)]) {
		return YES;
	}
	
	return %orig;
}
%end	/// %hook CALayer

%hook CLKDevice
%new
- (CGRect)actualScreenBounds {
	CGFloat screenScale = [[self.nrDevice valueForProperty:@"screenScale"] floatValue];
	CGSize screenSize = [[self.nrDevice valueForProperty:@"screenSize"] CGSizeValue];
	
	return (CGRect){
		CGPointZero,
		{ screenSize.width / screenScale, screenSize.height / screenScale }
	};
}

%new
- (CGFloat)actualScreenCornerRadius {
	CGFloat screenScale = [[self.nrDevice valueForProperty:@"screenScale"] floatValue];
	CGSize screenSize = [[self.nrDevice valueForProperty:@"screenSize"] CGSizeValue];
	CGRect screenBounds = self.screenBounds;
	
	return (((screenSize.width / screenScale) * (screenSize.height / screenScale)) / (CGRectGetWidth(screenBounds) * CGRectGetHeight(screenBounds))) * self.screenCornerRadius;
}
%end	/// %hook CLKDevice

%hook CLKVideoPlayerView
- (void)layoutSubviews {
	%orig;
	
	[self.superview.subviews[2] setBackgroundColor:UIColor.clearColor];
	[self.superview.subviews[3] setBackgroundColor:UIColor.clearColor];
	
	if (self.superview.subviews.count >= 6) {
		[self.superview.subviews[5] setBackgroundColor:UIColor.clearColor];
	}
}
%end	/// %hook CLKVideoPlayerView

%hook NTKAlbumEmptyView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKAlbumEmptyView

%hook NTKAnalogFaceView
- (void)layoutSubviews {
	%orig;
	
	if (self.contentView) {
		[self.contentView setBackgroundColor:UIColor.clearColor];
	}
}
%end	/// %hook NTKAnalogFaceView

%hook NTKAnalogScene
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKAnalogScene

%hook NTKCircularAnalogDialView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKCircularAnalogDialView

%hook NTKComplicationDataSource
+ (Class)dataSourceClassForComplicationType:(unsigned long long)type family:(long long)family forDevice:(id)arg3 {
	return nil;
}
%end	/// %hook NTKComplicationDataSource

%hook NTKFaceViewController
%property (nonatomic, strong) UIVisualEffectView* effectView;

- (id)initWithFace:(id)arg1 configuration:(id /* block */)arg2 {
	id r = %orig;
	
	if ([[LWPreferences sharedInstance] backgroundEnabled]) {
	self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:17]];
	}
	
	return r;
}

- (void)viewDidLayoutSubviews {
	%orig;
	
	[self.faceView setClipsToBounds:YES];
	[self.faceView.layer setCornerRadius:self.face.device.screenCornerRadius];

#if __clang_major__ >= 9
	if (@available(iOS 13, *)) {
		[self.faceView.layer setCornerCurve:kCACornerCurveContinuous];
	}
#endif
	
	if (![self.faceView.subviews containsObject:self.effectView]) {
		[self.faceView insertSubview:self.effectView atIndex:0];
	}
	
	[self.effectView setFrame:self.view.bounds];
}
%end	/// %hook NTKCompanionFaceViewController

%hook NTKExplorerDialView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook NTKExplorerDialView

%hook NTKFaceViewController
- (BOOL)_canShowWhileLocked {
	return YES;
}
%end	/// %hook NTKCompanionFaceViewController

%hook NTKPrideDigitalFaceView
- (void)layoutSubviews {
	%orig;
	
#if !TARGET_OS_SIMULATOR
	UIView* _bandsView = MSHookIvar<UIView*>(self, "_bandsView");
	[_bandsView removeFromSuperview];
	[self insertSubview:_bandsView atIndex:1];
#endif
}
%end

%hook NTKRoundedCornerOverlayView
- (void)layoutSubviews {
	self.hidden = YES;
}
%end	/// %hook NTKRoundedCornerOverlayView

%hook NTKSiderealDialBackgroundView
- (void)layoutSubviews {
	%orig;
	
	self.layer.cornerRadius = CGRectGetWidth(self.bounds) / 2;
	self.clipsToBounds = YES;
}
%end	/// %hook NTKSiderealDialBackgroundView

%hook NTKSiderealFaceView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKSiderealFaceView

%hook NTKVictoryAnalogBackgroundView
- (void)setBackgroundColor:(UIColor*)arg1 {
	if (CGColorEqualToColor(arg1.CGColor, UIColor.blackColor.CGColor)) {
		%orig(UIColor.clearColor);
	} else {
		%orig;
	}
}
%end	/// %hook NTKVictoryAnalogBackgroundView

%hook NTKUpNextCollectionView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}
%end	/// %hook NTKUpNextCollectionView

%hook SKView
- (void)setBackgroundColor:(UIColor*)arg1 {
	%orig(UIColor.clearColor);
}

- (void)setAllowsTransparency:(BOOL)arg1 {
	%orig(YES);
}
%end	/// %hook SKView
%end	// %group SpringBoard



%ctor {
	@autoreleasepool {
		LWPreferences* preferences = [LWPreferences sharedInstance];
		NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
		
		if (bundleIdentifier && preferences.enabled) {
			%init();
			
			if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
				%init(SpringBoard);
			}
		}
	}
}