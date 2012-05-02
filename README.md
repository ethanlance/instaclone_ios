Why instaclone_ios?
==================

So I wanted to learn iOS / objective-c.  I decided why not use Instagram as my muse?  Except for the camera filters and geo tagging, I cloned most of the basic flow af that app. My goal was to understand how views, api calls, core-data and basic objective-c syntax works.  
This is not meant to be a finished product and I don't claim this code to be any good.  

Also, instaclone_ios uses storyboards and ARC.  Only works on iOS 5.


Also Install:
========================


Facebook SDK
------------
First thing the app does on launch is present you with a login screen.  It needs to authenticate you with Facebook.  Once authenticated the app sends data to the Web App ( see below ) and the web app creates you and/or logs you in.

<code>
git clone git://github.com/facebook/facebook-ios-sdk.git
</code>
<code>
cd % ~/facebook-ios-sdk/scripts/build_facebook_ios_sdk_static_lib.sh
</code>

This will create the static library under the <PROJECT_HOME>/lib/facebook-ios-sdk folder (e.g. ~/facebook-ios-sdk/lib/facebook-ios-sdk). You may then drag the facebook-ios-sdk folder into the app Xcode project to include the iOS Facebook SDK static library.

More info on this here https://developers.facebook.com/docs/mobile/ios/build/


Django Web App
--------------

Git clone the accompanying django web app I wrote if you want to actually login and upload photos.  

<code>
git clone  git@github.com:ethanlance/instaclone_django.git
</code>
