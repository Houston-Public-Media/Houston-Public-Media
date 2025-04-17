//
//  WatchView.swift
//  HPM
//
//  Created by Jared Counts on 3/21/25.
//


//import SwiftUI
//
//struct ArticleView: View {
//	@EnvironmentObject var data: StationData
//	var id: Int
//	var body: some View {
//		WebView(payload: html_build(article: data.loadedArticles[id]), viewType: .string)
//			.frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
//	}
//}
//
//#Preview {
//	WatchView().environmentObject(StationData())
//}
//
//func coauthors_echo(coauthors: [Coauthor]?) -> String {
//	var output = ""
//	for authors in coauthors ?? [] {
//		if !output.isEmpty {
//			output += " / "
//		}
//		output += "<address class=\"vcard author\"><a href=\"https://www.houstonpublicmedia.org/articles/author/\(authors.user_nicename)/\" title=\"Posts by \(authors.display_name)\" class=\"author url fn\" rel=\"author\">\(authors.display_name)</a></address>"
//	}
//	return output
//}
//
//func html_build(article: ArticleData?) -> String {
//	if article == nil {
//		return ""
//	} else {
//		return """
//<!DOCTYPE html>
//<html lang="en-US" xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" dir="ltr" prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb#">
//	<head>
//		<meta charset="UTF-8">
//		<title>\(article?.title.rendered ?? "") &#8211; Houston Public Media</title>
//		<style>img:is([sizes="auto" i], [sizes^="auto," i]) { contain-intrinsic-size: 3000px 1500px }</style>
//		<link rel="profile" href="https://gmpg.org/xfn/11" />
//		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=5" />
//		<meta name="theme-color" content="#f5f5f5" />
//		<link rel='stylesheet' id='hpm-css-css' href='https://assets.houstonpublicmedia.org/app/themes/hpmv4/style.css?ver=20240930-1' type='text/css' media='all' />
//		<link rel="canonical" href="\(article?.link ?? "")" />
//	</head>
//	<body class="post-template-default single single-post single-format-standard">
//		<div id="page" class="hfeed site">
//			<div id="content" class="site-content">
//				<div id="primary" class="content-area">
//					<main id="main" class="site-main" role="main">
//						<article class="post type-post">
//							<header class="entry-header">
//								<h1 class="entry-title">\(article?.title.rendered ?? "")</h1>
//								\(article?.excerpt.rendered ?? "")
//								<div class="byline-date">
//									<div class="byline-date-text">
//										\(coauthors_echo(coauthors: article?.coauthors)) | <span class="posted-on"><span class="screen-reader-text">Posted on </span><time class="entry-date published updated" datetime="\(wpDateFormatter(date: article?.date_gmt))">\(wpDateFormatter(date: article?.date_gmt))</time></span>
//									</div>
//								</div>
//							</header>
//							<div class="entry-content">
//								\(article?.content.rendered ?? "")
//							</div>
//						</article>
//					</main>
//				</div>
//			</div>
//		</div>
//		<script type="text/javascript" src="https://assets.houstonpublicmedia.org/app/themes/hpmv4/js/main.js?ver=20240926-1" id="hpm-js-js"></script>
//	</body>
//</html>
//"""
//		
//	}
//}
