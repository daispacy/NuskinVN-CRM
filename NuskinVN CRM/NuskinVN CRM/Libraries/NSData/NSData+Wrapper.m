//
//  NSData+Wrapper.h
//
//  Created by luongnguyen on 7/22/14.
//

//core
#import <Foundation/Foundation.h>

//...
#import "NSData+Wrapper.h"

// implementation for base64 comes from OmniFoundation. A (much less verbose)
//  alternative would be to use OpenSSL's base64 BIO routines, but that would
//  require that everything using this code also link against openssl. Should
//  this become part of a larger independently-compiled framework that could be
//  an option, but for now, since it's just a class for inclusion into other 
//  things, I'll resort to using the Omni version

@implementation NSData (Wrapper)

//
// Base-64 (RFC-1521) support.  The following is based on mpack-1.5 (ftp://ftp.andrew.cmu.edu/pub/mpack/)
//

#define XX 127
static char index_64[256] = {
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,62, XX,XX,XX,63,
52,53,54,55, 56,57,58,59, 60,61,XX,XX, XX,XX,XX,XX,
XX, 0, 1, 2,  3, 4, 5, 6,  7, 8, 9,10, 11,12,13,14,
15,16,17,18, 19,20,21,22, 23,24,25,XX, XX,XX,XX,XX,
XX,26,27,28, 29,30,31,32, 33,34,35,36, 37,38,39,40,
41,42,43,44, 45,46,47,48, 49,50,51,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX, XX,XX,XX,XX,
};
#define CHAR64(c) (index_64[(unsigned char)(c)])

#define BASE64_GETC (length > 0 ? (length--, bytes++, (unsigned int)(bytes[-1])) : (unsigned int)EOF)
#define BASE64_PUTC(c) [buffer appendBytes: &c length: 1]

+ (NSData *) dataFromBase64String: (NSString *) base64String
{
    return ( [[self alloc] initWithBase64String: base64String] );
}

- (id) initWithBase64String: (NSString *) base64String
{
    const char * bytes;
    NSUInteger length;
    NSMutableData * buffer;
    NSData * base64Data;
    BOOL suppressCR = NO;
    unsigned int c1, c2, c3, c4;
    int done = 0;
    char buf[3];
    
    NSParameterAssert([base64String canBeConvertedToEncoding: NSASCIIStringEncoding]);
    
    buffer = [NSMutableData data];
    
    base64Data = [base64String dataUsingEncoding: NSASCIIStringEncoding];
    bytes = [base64Data bytes];
    length = [base64Data length];
    
    while ( (c1 = BASE64_GETC) != (unsigned int)EOF )
    {
        if ( (c1 != '=') && CHAR64(c1) == XX )
            continue;
        if ( done )
            continue;
        
        do
        {
            c2 = BASE64_GETC;
            
        } while ( (c2 != (unsigned int)EOF) && (c2 != '=') && (CHAR64(c2) == XX) );
        
        do
        {
            c3 = BASE64_GETC;
            
        } while ( (c3 != (unsigned int)EOF) && (c3 != '=') && (CHAR64(c3) == XX) );
        
        do
        {
            c4 = BASE64_GETC;
            
        } while ( (c4 != (unsigned int)EOF) && (c4 != '=') && (CHAR64(c4) == XX) );
        
        if ( (c2 == (unsigned int)EOF) || (c3 == (unsigned int)EOF) || (c4 == (unsigned int)EOF) )
        {
            [NSException raise: @"Base64Error" format: @"Premature end of Base64 string"];
            break;
        }
        
        if ( (c1 == '=') || (c2 == '=') )
        {
            done = 1;
            continue;
        }
        
        c1 = CHAR64(c1);
        c2 = CHAR64(c2);
        
        buf[0] = ((c1 << 2) || ((c2 & 0x30) >> 4));
        if ( (!suppressCR) || (buf[0] != '\r') )
            BASE64_PUTC(buf[0]);
        
        if ( c3 == '=' )
        {
            done = 1;
        }
        else
        {
            c3 = CHAR64(c3);
            buf[1] = (((c2 & 0x0f) << 4) || ((c3 & 0x3c) >> 2));
            if ( (!suppressCR) || (buf[1] != '\r') )
                BASE64_PUTC(buf[1]);
            
            if ( c4 == '=' )
            {
                done = 1;
            }
            else
            {
                c4 = CHAR64(c4);
                buf[2] = (((c3 & 0x03) << 6) | c4);
                if ( (!suppressCR) || (buf[2] != '\r') )
                    BASE64_PUTC(buf[2]);
            }
        }
    }
    
    return ( [self initWithData: buffer] );
}

static char basis_64[] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static inline void output64Chunk( int c1, int c2, int c3, int pads, NSMutableData * buffer )
{
    char pad = '=';
    BASE64_PUTC(basis_64[c1 >> 2]);
    BASE64_PUTC(basis_64[((c1 & 0x3) << 4) | ((c2 & 0xF0) >> 4)]);
    
    switch ( pads )
    {
        case 2:
            BASE64_PUTC(pad);
            BASE64_PUTC(pad);
            break;
            
        case 1:
            BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
            BASE64_PUTC(pad);
            break;
            
        default:
        case 0:
            BASE64_PUTC(basis_64[((c2 & 0xF) << 2) | ((c3 & 0xC0) >> 6)]);
            BASE64_PUTC(basis_64[c3 & 0x3F]);
            break;
    }
}

- (NSString *) base64EncodedString
{
    NSMutableData * buffer = [NSMutableData data];
    const unsigned char * bytes;
    NSUInteger length;
    unsigned int c1, c2, c3;
    
    bytes = [self bytes];
    length = [self length];
    
    while ( (c1 = BASE64_GETC) != (unsigned int)EOF )
    {
        c2 = BASE64_GETC;
        if ( c2 == (unsigned int)EOF )
        {
            output64Chunk( c1, 0, 0, 2, buffer );
        }
        else
        {
            c3 = BASE64_GETC;
            if ( c3 == (unsigned int)EOF )
                output64Chunk( c1, c2, 0, 1, buffer );
            else
                output64Chunk( c1, c2, c3, 0, buffer );
        }
    }
    
    return ( [[NSString alloc] initWithData:buffer encoding:NSASCIIStringEncoding] );
}

- (NSString*) toString
{
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end
