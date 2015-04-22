//
//  main.m
//  cartool
//
//  Created by Steven Troughton-Smith on 14/07/2013.
//  Copyright (c) 2013 High Caffeine Content. All rights reserved.
//  Modified by Levi Brown <mailto:levigroker@gmail.com> April 21, 2015
//

#import <Foundation/Foundation.h>
#include <libproc.h>

@interface CUICommonAssetStorage : NSObject

-(NSArray *)allAssetKeys;
-(NSArray *)allRenditionNames;

-(id)initWithPath:(NSString *)p;

-(NSString *)versionString;

@end

@interface CUINamedImage : NSObject

@property(readonly) CGSize size;
@property(readonly) double scale;
@property(readonly) long long idiom;

-(CGImageRef)image;

@end

@interface CUIRenditionKey : NSObject
@end

@interface CUIThemeFacet : NSObject

+(CUIThemeFacet *)themeWithContentsOfURL:(NSURL *)u error:(NSError **)e;

@end

@interface CUICatalog : NSObject

@property(readonly) bool isVectorBased;

-(id)initWithName:(NSString *)n fromBundle:(NSBundle *)b;
-(id)allKeys;
-(id)allImageNames;
-(CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s;
-(CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s deviceIdiom:(int)idiom;
-(NSArray *)imagesWithName:(NSString *)n;

@end

#define kCoreThemeIdiomPhone 1
#define kCoreThemeIdiomPad 2

void CGImageWriteToFile(CGImageRef image, NSString *path)
{
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
    }
    
    CFRelease(destination);
}


void exportCarFileAtPath(NSString * carPath, NSString *outputDirectoryPath)
{
    NSError *error = nil;
    
    outputDirectoryPath = [outputDirectoryPath stringByExpandingTildeInPath];
    
    CUIThemeFacet *facet = [CUIThemeFacet themeWithContentsOfURL:[NSURL fileURLWithPath:carPath] error:&error];
    
    CUICatalog *catalog = [[CUICatalog alloc] init];
    
    /* Override CUICatalog to point to a file rather than a bundle */
    [catalog setValue:facet forKey:@"_storageRef"];
    
    /* CUICommonAssetStorage won't link */
    CUICommonAssetStorage *storage = [[NSClassFromString(@"CUICommonAssetStorage") alloc] initWithPath:carPath];
    
    for (NSString *key in [storage allRenditionNames])
    {
        printf("%s\n", [key UTF8String]);
        
        NSArray *images = [catalog imagesWithName:key];
        for( CUINamedImage *image in images )
        {
            if( CGSizeEqualToSize(image.size, CGSizeZero) )
                printf("\tappears to have a PDF implementation\n");
            else
            {
                CGImageRef cgImage = [image image];
                NSString *idiom = @"";
                switch( image.idiom )
                {
                    case kCoreThemeIdiomPhone:
                        idiom = @"~iphone";
                        break;
                    case kCoreThemeIdiomPad:
                        idiom = @"~ipad";
                        break;
                    default:
                        break;
                }
                NSString *scale = image.scale > 1.0 ? [NSString stringWithFormat:@"@%dx", (int)floor(image.scale)] : @"";
                NSString *name = [NSString stringWithFormat:@"%@%@%@.png", key, idiom, scale];
                printf("\t%s\n", [name UTF8String]);
                if( outputDirectoryPath )
                    CGImageWriteToFile(cgImage, [outputDirectoryPath stringByAppendingPathComponent:name]);
            }
        }
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        if (argc < 2 || argc > 3)
        {
            //Default executable name
            NSString *execName = @"cartool";

            //Attempt to determine executable name from executable path
            char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
            int res = proc_pidpath(getpid(), pathbuf, sizeof(pathbuf));
            if (res > 0)
            {
                //We have the full path, so we'll take the last path component as our executable name
                NSString *path = [NSString stringWithUTF8String:pathbuf];
                execName = [path lastPathComponent];
            }

            printf("Usage: %s <car_file> [output_directory]\n", [execName cStringUsingEncoding:NSUTF8StringEncoding]);
            return -1;
        }
        
        exportCarFileAtPath([NSString stringWithUTF8String:argv[1]], argc > 2 ? [NSString stringWithUTF8String:argv[2]] : nil);
    }
    return 0;
}