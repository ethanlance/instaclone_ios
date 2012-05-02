Why instaclone_ios?
==================

So I wanted to learn iOS / objective-c.  I decided why not use Instagram as my muse?  Except for the camera filters and geo tagging, I cloned most of the basic flow af that app. My goal was to understand how views, api calls, core-data and basic objective-c syntax works.  
This is not meant to be a finished product and I don't claim this code to be any good.  

Also, instaclone_ios uses storyboards and ARC.  Only works on iOS 5.


Other things to install:
========================


FACEBOOK CONNECT:

For the app to work you will need to git clone and install the FB Connect framework. Here's how:

<code>
git clone git://github.com/facebook/facebook-ios-sdk.git

cd % ~/facebook-ios-sdk/scripts/build_facebook_ios_sdk_static_lib.sh
</code>

This will create the static library under the <PROJECT_HOME>/lib/facebook-ios-sdk folder (e.g. ~/facebook-ios-sdk/lib/facebook-ios-sdk). You may then drag the facebook-ios-sdk folder into the app Xcode project to include the iOS Facebook SDK static library.

More info on this here https://developers.facebook.com/docs/mobile/ios/build/


INSTACLONE_DJANGO:

Git clone the accompanying django web app I wrote if you want to actually login and upload photos.  

<code>
git@github.com:ethanlance/instaclone_django.git
</code>
