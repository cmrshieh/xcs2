//
//  XCProject.m
//  xcs
//
//  Created by Oleksandr Tymoshenko on 2013-04-28.
//  Copyright (c) 2013 Bluezbox Software. All rights reserved.
//

#import "XCProject.h"
#import "XCElement.h"

#define TMP_BUFFER 128

enum Token
{
    tokEOF = -1,
    tokString = -2,
};

#define kEOFChar    (-1)

// helper function
BOOL isbare(int ch)
{
    return ((ch >= 'a') && (ch <= 'z'))
    || ((ch >= 'A') && (ch <= 'Z'))
    || ((ch >= '0') && (ch <= '9'))
    || (ch == '_') || (ch == '/') || (ch == '.');
}

@interface XCProject() {
    int currentToken;
}
// Lexer part
- (int)nextChar;
- (void)prevChar;
- (int)nextToken;
- (void)consumeQuotedString;
- (void)consumeBareString:(int)firstChar;
- (void)consumeComment;
- (void)consumeOneLineComment;

// Parser part
- (XCArray*) parseArray;
- (XCDictionary*) parseDictionary;
- (XCElement*) parseElement;
- (void)parserFailure:(NSString*)msg onCodeLine:(int)line;
@end

@implementation XCProject

- (id)init
{
    self = [super init];
    if (self) {
        _tokValue = nil;
        _lexerPos = 0;
        _row = 1;
        _col = 0;
        _pbxData = nil;
    }
    return self;
}

- (BOOL)parse:(NSString*)data
{
    self.pbxData = data;
    int tok;
    
    while ((tok = [self nextToken]) != tokEOF) {
        if (tok == '{') {
            parserRoot = [self parseDictionary];
            if (parserRoot == nil) {
                NSLog(@"parse failed");
                return NO;
            }
            
            [parserRoot dump];
                
        }
        else {
            [self parserFailure:@"Failed to parse top-level dictionary" onCodeLine:__LINE__];
        }
    }
    
    return YES;
}

- (XCElement*)parseElement
{
    int tok;

    tok = [self nextToken];
    if (tok == tokEOF)
        return nil;
    if (tok == '{')
        return [self parseDictionary];

    if (tok == '(')
        return [self parseArray];

    if (tok == tokString) {
        XCString *el = [[XCString alloc] init];
        el.stringValue = self.tokValue;
        return el;
    }
    
    return nil;
}

- (XCArray*)parseArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int tok;
    XCElement *value;
    do {
        value = [self parseElement];
        if (value) {
            [array addObject:value];
            tok = [self nextToken];
        }
        
        // End of array
        if (currentToken == ')')
            break;
        // The only other option is ','
        if (currentToken != ',') {
            [self parserFailure:@"Unexpected token while parsing array" onCodeLine:__LINE__];
            return nil;
        }

    } while(currentToken != tokEOF);
    
    XCArray *el = [[XCArray alloc] init];
    el.arrayValue = [NSArray arrayWithArray:array];
    return el;
}

- (XCDictionary*)parseDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    int tok = [self nextToken];
    NSString *key;
    XCElement *value;
    while (tok != '}') {
        if (tok == tokEOF) {
            [self parserFailure:@"Unexpected EOF while parsing dictionary" onCodeLine:__LINE__];
            return nil;
        }
        if (tok != tokString) {
            [self parserFailure:@"Key object is not a string while parsing dictionary" onCodeLine:__LINE__];
            return nil;
        }
        
        key = self.tokValue;
        
        tok = [self nextToken];
        if (tok != '=') {
            [self parserFailure:@"No '=' while parsing dictionary" onCodeLine:__LINE__];
            return nil;
        }
        
        value = [self parseElement];
        if (value == nil) {
            [self parserFailure:@"Failed to parse value object" onCodeLine:__LINE__];
            return nil;
        }

        [dict setValue:value forKey:key];
        
        tok = [self nextToken];
        if (tok != ';') {
            [self parserFailure:@"No ';' while parsing dictionary" onCodeLine:__LINE__];
            return nil;
        }
        
        tok = [self nextToken];
    }
    
    XCDictionary *result = [[XCDictionary alloc] init];
    result.dictValue = [NSDictionary dictionaryWithDictionary:dict];
    return result;
}

- (void)parserFailure:(NSString*)msg onCodeLine:(int)line
{
    NSString *excMsg = [NSString stringWithFormat:@"line %ld, col %ld:  %@", _row, _col, msg];
    NSException *exception = [NSException 
                              exceptionWithName:@"ParserFailure" 
                              reason:excMsg 
                              userInfo:nil];
    @throw exception;
}


//
// Lexer code
//
- (int)nextChar
{
    int ch;

    if (_lexerPos >= [_pbxData length])
        return kEOFChar;
   
    ch = [_pbxData characterAtIndex:(_lexerPos++)];

    _prevRow = _row;
    _prevCol = _col;

    if (_nextLine) {
        _col = 1;
        _row++;
        _nextLine = NO;
    }
    else
        _col++;

    if (ch == '\n')
        _nextLine = YES;

    return ch;
}

// This function can't be called several times in row
// should be used only once
- (void)prevChar
{

    if (_lexerPos > 0) {
        _col = _prevCol;
        _row = _prevRow;
        _lexerPos--;
    }
}

- (int)nextToken
{
    int ch;
    
    while ((ch = [self nextChar]) != kEOFChar) {
        // Eat top-level spaces
        if (isspace(ch))
            continue;
        
        // terminal characters
        if ((ch == '{') || (ch == '}') || (ch == '(') || (ch == ')') ||
            (ch == ',') || (ch == ';') || (ch == '='))
            return (currentToken = ch);
        
        if (ch == '/') {
            int nextCh = [self nextChar];
            if (nextCh == '/') {
                [self consumeOneLineComment];
                continue;
            }
            
            if (nextCh == '*') {
                [self consumeComment];
                continue;
            }
            
            // fallback to bare string case
            [self prevChar];
        }
        
        // Quoted string case
        if (ch == '"') {
            [self consumeQuotedString];
            return (currentToken = tokString);
        }
        
        // Bare string case
        if (isbare(ch)) {
            [self consumeBareString:ch];
            return (currentToken = tokString);
        }
    }
    
    return tokEOF;
}

- (void)consumeOneLineComment
{
    int ch;
    while ((ch = [self nextChar]) != tokEOF)
        if (ch == '\n')
            break;
}

- (void)consumeComment
{
    int ch, nextCh;
    ch = [self nextChar];
    while (ch != tokEOF) {
        if (ch == '*') {
            nextCh = [self nextChar];
            if (nextCh == '/')
                return;
            else
                ch = nextCh;
        }
        else
            ch = [self nextChar];
    }
}

- (void)consumeQuotedString
{
    unichar uch[TMP_BUFFER];
    int i;
    int ch, escCh;
    BOOL quoteClosed = NO;
    
    self.tokValue = nil;
    i = 0;
    NSMutableString *tmpString = [[NSMutableString alloc] init];
    
    ch = [self nextChar];
    while (ch != tokEOF) {
        if (ch == '"') {
            quoteClosed = YES;
            break;
        }
        
        // safe, it can't be tokEOF
        if (ch == '\\') {
            escCh = [self nextChar];
            switch (escCh) {
            case 'r':
                ch = '\r';
                break;
            case 'n':
                ch = '\n';
                break;
            case '\\':
                ch = '\\';
                break;
            case '"':
                ch = '"';
                break;
            default:
                [self parserFailure:@"Invalid escape sequence" onCodeLine:__LINE__];
                break;
            }
        }
        uch[i++] = ch;
        if (i == TMP_BUFFER) {
            [tmpString appendString:[NSString stringWithCharacters:uch length:i]];
            i = 0;
        }
        ch = [self nextChar];
    }

    if (!quoteClosed) {
        [self parserFailure:@"No closing quote before EOF" onCodeLine:__LINE__];
    }
    
    if (i)
        [tmpString appendString:[NSString stringWithCharacters:uch length:i]];
    
    self.tokValue = [NSString stringWithString:tmpString];
}

- (void)consumeBareString:(int)firstChar
{
    unichar uch[TMP_BUFFER];
    int i;
    int ch;
    
    self.tokValue = nil;
    uch[0] = firstChar;
    i = 1;
    NSMutableString *tmpString = [[NSMutableString alloc] init];
    
    ch = [self nextChar];
    while (ch != tokEOF) {
        if (!isbare(ch)) {
            // unroll to previous position
            [self prevChar];
            break;
        }
        // safe, it can't be tokEOF
        // TODO: escape sequences
        uch[i++] = ch;
        if (i == TMP_BUFFER) {
            [tmpString appendString:[NSString stringWithCharacters:uch length:i]];
            i = 0;
        }
        ch = [self nextChar];
    }
    
    if (i)
        [tmpString appendString:[NSString stringWithCharacters:uch length:i]];
    
    self.tokValue = [NSString stringWithString:tmpString];
}

@end
