//
//  AppController.h
//
//  Created by Nadan Gergeo on 2011-03-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject <NSXMLParserDelegate> /* Specify a superclass (eg: NSObject or NSView) */ {
	
	NSString *tvShowScriptTemplate;
	NSString *tvShow;
	NSMutableArray *tvShows;
	IBOutlet NSTextField *PMSField;
	IBOutlet NSTextField *tvShowsCommandField;
	IBOutlet NSTextField *tvShowsSectionField;

}
- (IBAction)installTvShows:(id)sender;
- (void)loadDataFromXML:(NSString*) URL;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (IBAction)quit:(id)sender;
@end
