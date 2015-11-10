//
//  ViewController.m
//  MCLocalization
//
//  Created by Baglan on 3/14/13.
//  Copyright (c) 2013 MobileCreators. All rights reserved.
//

#import "ViewController.h"
#import "MCLocalization.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localize) name:MCLocalizationLanguageDidChangeNotification object:nil];
    
    [self localize];
}

- (void)localize
{
    _greetingLabel.text = [[MCLocalization sharedInstance] stringForKey:@"greeting"];
    _messageLabel.text = [[MCLocalization sharedInstance] stringForKey:@"message"];
    _placeholderLabel.text = [[MCLocalization sharedInstance] stringForKey:@"glory" substitutes:@{@"%name%":@"Man United"}];
    _mustacheLabel.text = [[MCLocalization sharedInstance] stringForKey:@"lovely-mustache" substitutes:@{@"{{mustache}}":[[MCLocalization sharedInstance] stringForKey:@"mustache"]}];
    _noKeyLabel.text = [[MCLocalization sharedInstance] stringForKey:@"missing-key-hahahah" noKeyPlaceholder:@"This key is missing!"];
    NSLog(@"--- %@", [[MCLocalization sharedInstance] stringForKey:@"non-existing-key"]);
}

- (IBAction)switchToRussian:(id)sender
{
    [MCLocalization sharedInstance].language = @"ru";
}

- (IBAction)switchToEnglish:(id)sender
{
    [MCLocalization sharedInstance].language = @"en";
}

@end
