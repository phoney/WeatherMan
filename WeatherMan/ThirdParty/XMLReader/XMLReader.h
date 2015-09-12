//
//  XMLReader.h
//
//

#import <Foundation/Foundation.h>

@interface XMLReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
}

@property NSError* error;

+ (NSDictionary *)dictionaryForPath:(NSString *)path;
+ (NSDictionary *)dictionaryForXMLData:(NSData *)data;
+ (NSDictionary *)dictionaryForXMLString:(NSString *)string;

@end

@interface NSDictionary (XMLReaderNavigation)

- (id)retrieveForPath:(NSString *)navPath;

@end