//
//  MCLocalization.h
//  MCLocalization
//
//  Created by Baglan on 3/14/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCLocalizationDataSource.h"

#define MCLocalizationLanguageDidChangeNotification @"MCLocalizationLanguageDidChangeNotification"

@interface MCLocalization : NSObject

@property (nonatomic, retain) id<MCLocalizationDataSource>dataSource;

@property (nonatomic, copy) NSString * language;
@property (nonatomic, readonly) NSArray * supportedLanguages;
@property (nonatomic, readonly) NSString * systemLanguage;

// String using this placeholder will be returned in case a key in not found
// {key} and {language} substring will be substituted for corresponding values
// Default value is nil
@property (nonatomic, copy) NSString * noKeyPlaceholder;

// The `key` is used by -valueForKeyPath:, so it can also search through nested dictionaries.
+ (MCLocalization *)sharedInstance;

// language file loading
- (void)loadFromURL:(NSURL *)JSONFileURL defaultLanguage:(NSString *)defaultLanguage;
- (void)loadFromLanguageURLPairs:(NSDictionary *)languageURLPairs defaultLanguage:(NSString *)defaultLanguage;

// convenience
- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key substitutes:(NSDictionary *)substitutes;
- (NSString *)stringForKey:(NSString *)key noKeyPlaceholder:(NSString *)noKeyPlaceholder;
- (NSString *)stringForKey:(NSString *)key substitutes:(NSDictionary *)substitutes noKeyPlaceholder:(NSString *)noKeyPlaceholder;

// designated
- (NSString *)stringForKey:(NSString *)key language:(NSString *)language substitutes:(NSDictionary *)substitutes noKeyPlaceholder:(NSString *)noKeyPlaceholder;

// Legacy methods
+ (void)loadFromJSONFile:(NSString *)fileName defaultLanguage:(NSString *)defaultLanguage;

@end
