//
//  pbupload.m
//  pbupload
//
//  Created by quiprr on 12/24/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        NSData *data = [[NSFileHandle fileHandleWithStandardInput] availableData];
        if (!data) return 1; // This will just hang if no data is in stdin/*data so is really useless at this point
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://pastebin.com/api/api_post.php"]];
        [request addValue:@"pbupload/1.0.0" forHTTPHeaderField:@"User-Agent"];
        NSString *boundary = [NSString stringWithFormat:@"pbupload-%@", [[NSUUID UUID] UUIDString]];
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];

        NSDictionary *parameters = @{ @"api_dev_key": @"ktLvzDaXRCCVaqOAe8uddsBuASWE_Ftc",
                                      @"api_option": @"paste", 
                                      @"api_paste_code": dataString };
        NSMutableData *postData = [NSMutableData data];
        [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
            [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
        }];

        [request setHTTPBody:postData];
        NSURLSession *session = [NSURLSession sharedSession];
        NSLog(@"Sending HTTP request to Pastebin.com");
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (httpResponse.statusCode == 200) {
                NSLog(@"Response has status 200. Link copied to clipboard.");
                NSLog(@"Link: %@", responseString);
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = responseString;
            } else {
                NSLog(@"Request seems to have failed, as it did not return status code 200.\nContact 'quiprr@ametrine.dev' or @quiprr on Twitter with a screenshot.");
                NSLog(@"Response: %@", responseString);
            }
            dispatch_semaphore_signal(sema);   
        }];
        [dataTask resume];
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        NSLog(@"We done here.");
    }
    return 0;
}