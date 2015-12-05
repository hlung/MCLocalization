//
//  MCLocalization.m
//  MCLocalization
//
//  Created by Baglan on 3/14/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import "MCLocalization.h"
#import "MCLocalizationDummyDataSource.h"
#import "MCLocalizationSingleJSONFileDataSource.h"
#import "MCLocalizationOneJSONFilePerLanguageDataSource.h"

#define MCLOCALIZATION_PREFERRED_LOCALE_KEY @"MCLOCALIZATION_PREFERRED_LOCALE_KEY"

@interface MCLocalization ()

@end

@implementation MCLocalization {
    id<MCLocalizationDataSource> _dataSource;
    NSString * _language;
    NSDictionary * _cachedStrings;
}

// Singleton
// Taken from http://lukeredpath.co.uk/blog/a-note-on-objective-c-singletons.html
+ (MCLocalization *)sharedInstance
{
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+ (void)loadFromJSONFile:(NSString *)fileName defaultLanguage:(NSString *)defaultLanguage {
    [[MCLocalization sharedInstance] loadFromJSONFile:fileName defaultLanguage:defaultLanguage];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        self.dataSource = [MCLocalizationDummyDataSource new];
    }
    
    return self;
}

#pragma mark - Data source

- (void)setDataSource:(id<MCLocalizationDataSource>)dataSource
{
    _dataSource = dataSource;
    _cachedStrings = nil;
}

#pragma mark - Loading

- (void)loadFromJSONFile:(NSString *)JSONFilePath defaultLanguage:(NSString *)defaultLanguage
{
    NSURL * URL = [NSURL fileURLWithPath:JSONFilePath];
    return [self loadFromURL:URL defaultLanguage:defaultLanguage];
}

- (void)loadFromURL:(NSURL *)JSONFileURL defaultLanguage:(NSString *)defaultLanguage
{
    self.dataSource = [[MCLocalizationSingleJSONFileDataSource alloc] initWithURL:JSONFileURL defaultLanguage:defaultLanguage];
}

- (void)loadFromLanguageURLPairs:(NSDictionary *)languageURLPairs defaultLanguage:(NSString *)defaultLanguage
{
    self.dataSource = [[MCLocalizationOneJSONFilePerLanguageDataSource alloc] initWithLanguageURLPairs:languageURLPairs defaultLanguage:defaultLanguage];
}

#pragma mark - Supported languages

- (NSArray *)supportedLanguages
{
    return [self.dataSource supportedLanguages];
}

#pragma mark - Language

- (NSString *)sanitizeLanguage:(NSString *)language
{
    NSString * sanitizedLanguage = nil;
    
    // Use supplied language if supported
    if ([self.supportedLanguages indexOfObject:language] != NSNotFound) {
        sanitizedLanguage = language;
    } else {
        // If not, try to figure out language from preferred languages
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        sanitizedLanguage = [preferredLanguages firstObjectCommonWithArray:self.supportedLanguages];
    }
    
    // If language could not be figured out, use the default language
    if (!sanitizedLanguage) {
        sanitizedLanguage = [self.dataSource defaultLanguage];
    }
    
    return sanitizedLanguage;
}

- (NSString *)language
{
    if (!_language) {
        NSString *preferredLanguage = [[NSUserDefaults standardUserDefaults] stringForKey:MCLOCALIZATION_PREFERRED_LOCALE_KEY];
        preferredLanguage = [self sanitizeLanguage:preferredLanguage];
        [self setLanguage:preferredLanguage];
    }
    return _language;
}

- (void)setLanguage:(NSString *)language
{
    NSString * sanitizedLanguage = [self sanitizeLanguage:language];
    
    // Skip if the new setting is the same as the old one
//    if (![sanitizedLanguage isEqualToString:_language]) { // hlung: DON'T SKIP!
        // Check if new setting is supported by localization
        if ([self.supportedLanguages indexOfObject:sanitizedLanguage] != NSNotFound) {
            _language = [sanitizedLanguage copy];
            _cachedStrings = [self.dataSource stringsForLanguage:_language];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:MCLocalizationLanguageDidChangeNotification object:nil]];
        } else {
            _language = nil;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:_language forKey:MCLOCALIZATION_PREFERRED_LOCALE_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

- (NSDictionary *)stringsForLanguage:(NSString *)language
{
    if ([language isEqualToString:self.language]) {
        return _cachedStrings;
    }
    
    return [self.dataSource stringsForLanguage:language];
}

#pragma mark - String

- (NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key language:self.language substitutes:nil noKeyPlaceholder:nil];
}

- (NSString *)stringForKey:(NSString *)key substitutes:(NSDictionary *)substitutes
{
    return [self stringForKey:key language:self.language substitutes:substitutes noKeyPlaceholder:nil];
}

- (NSString *)stringForKey:(NSString *)key noKeyPlaceholder:(NSString *)noKeyPlaceholder
{
    return [self stringForKey:key language:self.language substitutes:nil noKeyPlaceholder:noKeyPlaceholder];
}

- (NSString *)stringForKey:(NSString *)key substitutes:(NSDictionary *)substitutes noKeyPlaceholder:(NSString *)noKeyPlaceholder
{
    return [self stringForKey:key language:self.language substitutes:substitutes noKeyPlaceholder:noKeyPlaceholder];
}

- (NSString *)stringForKey:(NSString *)key language:(NSString *)language substitutes:(NSDictionary *)substitutes noKeyPlaceholder:(NSString *)noKeyPlaceholder
{
    NSDictionary * langugeStrings = [self stringsForLanguage:language];
    
    NSObject * lookupResult = [langugeStrings valueForKeyPath:key];
    __block NSString * string = nil;
    if ([lookupResult isKindOfClass:NSString.class]) {
        string = (NSString *)lookupResult;
    } else if ([lookupResult isKindOfClass:NSNumber.class]) {
        string = [(NSNumber *)lookupResult stringValue];
    }

    if (!string) {
        if (noKeyPlaceholder == nil) { // if no placeholder provided, use the one from instance variable
            noKeyPlaceholder = self.noKeyPlaceholder;
        }
        if (noKeyPlaceholder) {
            string = noKeyPlaceholder;
            string = [string stringByReplacingOccurrencesOfString:@"{key}" withString:key];
            string = [string stringByReplacingOccurrencesOfString:@"{language}" withString:language];
        }
#if DEBUG
        NSLog(@"MCLocalization: no string for key %@ in language %@", key, language);
#endif
    }
    
    // substitutes
    if (string) {
        [substitutes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:NSString.class] && [obj isKindOfClass:NSString.class]) {
                string = [string stringByReplacingOccurrencesOfString:key withString:obj];
            }
        }];
    }
    
    return string;
}

@end
