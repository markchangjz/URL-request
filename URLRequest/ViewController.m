//
//  ViewController.m
//  URLRequest
//
//  Created by MarkChang on 2017/3/4.
//  Copyright © 2017年 MarkChang. All rights reserved.
//

// http://www.jianshu.com/p/a3f512998d07
// http://www.appcoda.com.tw/json-data-taipei-tutorial/

#import "ViewController.h"

#define GET_URL @"http://ipad-bjwb.bjd.com.cn/DigitalPublication/publish/Handler/APINewsList.ashx?date=20131129&startRecord=1&len=5&udid=1234567890&terminalType=Iphone&cid=213"
#define POST_URL @"http://ipad-bjwb.bjd.com.cn/DigitalPublication/publish/Handler/APINewsList.ashx"
#define POST_PARAMETERS @"date=20131129&startRecord=1&len=5&udid=1234567890&terminalType=Iphone&cid=213"

@interface ViewController () <NSURLConnectionDataDelegate>

@property (nonatomic) NSMutableData *tempData;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

//	[self get_sync];				// GET  同步處理 [NSURLConnection] [deprecated]
//	[self post_sync];				// POST 同步處理 [NSURLConnection] [deprecated]

//	[self get_async];				// GET  非同步處理 [NSURLConnection] [deprecated]
//	[self post_async];				// POST 非同步處理 [NSURLConnection] [deprecated]

	[self get_async_URLSession];	// GET  非同步處理 [NSURLSession]
	[self post_async_URLSession];	// POST 非同步處理 [NSURLSession]

//	[self get_async_URLSession_callback:^{
//		NSLog(@"Did Finish");
//	}];
}

- (void)get_sync {
	NSURL *url = [NSURL URLWithString:GET_URL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"GET"]; // 預設為 GET，可以不寫

	NSURLResponse *response = nil;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

	NSArray *array = dict[@"news"];
	for (NSDictionary *dict in array) {
		NSLog(@"[GET] title = %@", dict[@"title"]);
	}
}

- (void)post_sync {
	NSURL *url = [NSURL URLWithString:POST_URL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"]; // 使用 POST
	NSData *parameters = [POST_PARAMETERS dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:parameters]; // 設定 POST 參數

	NSURLResponse *response = nil;
	NSError *error;
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

	NSArray *array = dict[@"news"];
	for (NSDictionary *dict in array) {
		NSLog(@"[POST] title = %@", dict[@"title"]);
	}
}

- (void)get_async {
	NSURL *url = [NSURL URLWithString:GET_URL];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];

	// NSURLConnectionDataDelegate
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[connection start];
}

- (void)post_async {
	NSURL *url = [NSURL URLWithString:POST_URL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
	[request setHTTPMethod:@"POST"];
	NSData *parameters = [POST_PARAMETERS dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:parameters];

	// NSURLConnectionDataDelegate
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[connection start];
}

- (void)get_async_URLSession {
	NSURL *url = [NSURL URLWithString:GET_URL];

	NSURLSession *session = [NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

		NSArray *array = dict[@"news"];
		for (NSDictionary *dict in array) {
			NSLog(@"[GET] title = %@", dict[@"title"]);
		}
	}];
	[dataTask resume];
}

- (void)post_async_URLSession {
	NSURL *url = [NSURL URLWithString:POST_URL];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	NSData *parameters = [POST_PARAMETERS dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:parameters];

	NSURLSession *session =[NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

		NSArray *array = dict[@"news"];
		for (NSDictionary *dict in array) {
			NSLog(@"[POST] title = %@", dict[@"title"]);
		}
	}];
	[dataTask resume];
}

typedef void (^Callback)(void);

- (void)get_async_URLSession_callback:(Callback)callback {
	NSURL *url = [NSURL URLWithString:GET_URL];

	NSURLSession *session =[NSURLSession sharedSession];
	NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

		NSArray *array = dict[@"news"];
		for (NSDictionary *dict in array) {
			NSLog(@"[GET] title = %@", dict[@"title"]);
		}

		callback();
	}];
	[dataTask resume];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.tempData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.tempData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:self.tempData options:NSJSONReadingMutableContainers error:nil];

	NSArray *array = dict[@"news"];
	for (NSDictionary *dict in array) {
		NSLog(@"title = %@", dict[@"title"]);
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@",error);
}

@end
