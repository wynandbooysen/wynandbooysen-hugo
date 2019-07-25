---
title: "Talend Tips: Execute Multiple SQL UPDATE statements on MySQL using a single tMySQLrow component"
date: 2019-07-25
draft: false
images: 
  - /images/talend-logo.png
tags: 
  - Talend
  - MySQL
---

Had to pull data from one table and update two other tables recently on a MySQL server.  Looking for the most optimal route I'd thought it should be doable using a single tMySQLrow, but MySQL by default does not allow it.

It requires additional parameters to be configured when setting up the connection to allow this.  On the Db Connection add bash```allowMultiQueries=true``` under Additional parameters.  Multiple parameters should be joined using ‘&’ e.g. bash```noDatetimeStringSync=true&allowMultiQueries=true``` after which testing the connection should still return “connection successful”

Once done just add the statements to the Query window ending each with ‘;’ and enclosing all of them in double quotes.  You should now be able to execute multiple SQL queries within a single tMySQLrow
