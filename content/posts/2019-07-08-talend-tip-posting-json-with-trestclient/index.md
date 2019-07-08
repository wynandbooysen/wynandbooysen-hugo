---
title: "Talend Tips: Post JSON with tRESTClient"
date: 2019-07-08
draft: false
images: 
  - /images/talend-logo.png
tags: 
  - Talend
---

One common requirement when doing integration with API's is getting token's and using them to make further requests.  Sometimes they require you to POST credentials and/or other identification strings using JSON.

Unfortunately the tRESTClient component in Talend does not cater for this specifically, but it is easy enough to achive.

We'll add a tFixedFlowInput, followed by an tXMLMap before the tRESTClient.  The tFixedFlowInput is used to define the input variables, which is passed onto the tXMLMap.  Between the tXMLMap and the tRESTClient XML is automatically converted to JSON if the Content Type in the tRESTClient is set to JSON

![posting-json-with-trestclient](/images/posting-json-with-trestclient.png)

Edit the schema of the tFixedFlowInput with the variables needed in the JSON and populate the variables.

In the tXMLMap add the variables from the tFixedFlowInput into the 'root (loop)' section.

![posting-json-with-trestclient-txmlmap-body](/images/posting-json-with-trestclient-txmlmap-body.png)

Finally on the tRestClient, set the Content Type to JSON and under the Advance Settings make sure Drop JSON Request Root is ticked.
