//
//  PleechAppDelegate.h
//  Pleech
//
//  Created by Nadan Gergeo on 2011-03-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PleechAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
