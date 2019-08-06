---
title: "Retreive Passwords From Talend Repository Objects"
date: 2019-08-06
draft: false
images: 
  - /images/talend-logo.png
tags: 
  - Talend
  - Security
  - Decrypt
---
Working on Talend projects you may come across some projects where credentials weren't properly documented or maybe you forgot recording it while setting it up, if you are lucky they are just a plain text value in the contexts.  But about when they are Connections configured on a Repository level? Password: ******* ?
 
These are encrypted. You have the following options: 
 
* You can export the repository connection info and import it
* Reset the password and update the connection
* Create a new account and configure the job to use it instead
* Use Talend to decrypt the password value for you*
 
Talend encrypts these values for obvious reasons, but it also decrypts it upon usage.  Simply add a component like tDBInput adding the repository value and switch over to the code view. CTRL + F and search for ```routines.system.PasswordEncryptUtil.decryptPassword``` copy the string value in brackets. Then add a tJava component and add the following code and insert your unique value
 
```bash
String decryptedPassword = routines.system.PasswordEncryptUtil.decryptPassword("<YOUR UNIQUE VALUE>");
System.out.println(decryptedPassword);
```
 
Run the Talend job and the password should now be printed in clear text

