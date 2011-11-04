//
//  AppController.m
//
//  Created by Nadan Gergeo on 2011-03-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import <Foundation/Foundation.h>

@implementation AppController
- (id)init
{
	[super init];
	
	return self;
}

- (IBAction)installTvShows:(id)sender {
	
	NSString *PMS = [PMSField stringValue];
	NSString *tvShowsCommand = [tvShowsCommandField stringValue];
	NSString *tvShowsSection = [tvShowsSectionField stringValue];
	NSString *const XMLURL = [NSString stringWithFormat: @"http://%@/library/sections/%@/all",PMS,tvShowsSection];
	
	//Template for TV Show Scripts
	tvShowScriptTemplate = @"set tvShowName to \"<tvShowName>\"\n"
					"set pms to \"localhost:32400\"\n"
					"set section to \"2\"\n"
					"set computerName to computer name of (system info)\n"
					"\n"
					"-- Setup XML\n"
					"set tvShowsXMLURL to \"http://\" & pms & \"/library/sections/\" & section & \"/all\"\n"
					"set tvShowsXML to (do shell script \"curl \" & tvShowsXMLURL) as string\n"
					"set tvShowsXML to parse XML tvShowsXML encoding \"UTF-8\"\n"
					"set tvShows to XML contents of tvShowsXML\n"
					"\n"
					"repeat with tvShow in tvShows\n"
					"if title of XML attributes of tvShow = tvShowName then\n"
					"set tvShowKey to |ratingKey| of XML attributes of tvShow\n"
					"exit repeat\n"
					"end if\n"
					"end repeat\n"
					"\n"
					"-- Setup second XML\n"
					"set episodesXMLURL to \"http://\" & pms & \"/library/metadata/\" & tvShowKey & \"/allLeaves?unwatched=1\"\n"
					"set episodesXML to (do shell script \"curl \" & episodesXMLURL) as string\n"
					"set episodesXML to parse XML episodesXML encoding \"UTF-8\"\n"
					"set episodes to XML contents of episodesXML\n"
					"\n"
					"if item 1 of episodes is \"\" then\n"
					"say \"There are no unwatched episodes.\"\n"
					"else\n"
					"set episodeKey to |key| of XML attributes of item 1 of episodes\n"
					"set episodePath to \"http://\" & pms & \"/library/metadata/\" & tvShowKey & \"/allLeaves\"\n"
					"\n"
					"set triggerURL to \"http://\" & pms & \"/system/players/\" & computerName & \".local/Application/playMedia?path=\" & episodePath & \"\\\\&key=\" & episodeKey\n"
					"\n"
                    "--make sure Plex is running and then play episode\n"
                    "repeat\n"
                    "tell application \"System Events\"\n"
                    "set processList to (name of every process)\n"
                    "end tell\n"
                    "if processList contains \"Plex\" then\n"
                    "do shell script \"curl \" & triggerURL\n"
                    "exit repeat\n"
                    "else\n"
                    "tell application \"Plex\" to activate\n"
                    "delay (4)\n"
                    "end if\n"
                    "end repeat\n"
					"end if";
	
	// allocate a memory pool for our NSString Objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// NSObject which contains all the error information
	NSError *error;
	
	// get library directory
	NSArray *libDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask, YES);
	NSString *libDir = [libDirs objectAtIndex:0];
	
	tvShows = [NSMutableArray arrayWithObjects: nil];
	[self loadDataFromXML:XMLURL];
	
	NSLog(@"%i",[tvShows count]);
	
	for(int i = 0; i < [tvShows count]; i++)
	{
		// declare tvshow
		tvShow = [tvShows objectAtIndex: i];
		
		// set up script using template
		NSString *tvShowScript = [tvShowScriptTemplate stringByReplacingOccurrencesOfString:@"<tvShowName>" withString:tvShow];
		
		NSString *command = [tvShowsCommand stringByReplacingOccurrencesOfString:@"%tvshow%" withString:tvShow];
		
		// declare NSString filename and alloc string value
		NSString *filePath = [NSString stringWithFormat: @"%@/Speech/Speakable Items/%@.scpt",libDir,command];
		
		// write contents and check went ok
		if(![tvShowScript writeToFile: filePath atomically: YES encoding:NSUTF8StringEncoding error:&error]) {
			NSLog(@"We have a problem %@\r\n",[error localizedFailureReason]);
		}
		
		// compile applescript
		NSString *compileCommand = [NSString stringWithFormat: @"osacompile -o \"%@\" \"%@\"",filePath,filePath];
		//NSLog(@"%@", compileCommand);
		const char *compileCommandChar = [compileCommand UTF8String];
		system(compileCommandChar);
	}
	
	// unleash the allocated pool smithers
	[pool release];
	
}


- (void)loadDataFromXML:(NSString*) URL{
	
	NSURL* url = [NSURL URLWithString:URL];
	NSData* data = [NSData dataWithContentsOfURL: url];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithData: data];
	
	[parser setDelegate:self];
	[parser parse];
	[parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	
	if ([elementName isEqualToString:@"Directory"]) {
		
		NSString* title = [attributeDict valueForKey:@"title"];    
		[tvShows addObject: (NSString *)title];
		//NSLog(@"%@",title);
	}
}

- (IBAction)quit:(id)sender{
	exit(0);
}

@end
