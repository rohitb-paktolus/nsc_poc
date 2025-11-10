# frequent_flow

A Flutter-based mobile application designed to streamline access to frequently used modules and functionalities. FrequentFlow offers a user-friendly interface, modular design, and essential tools to enhance productivity and user experience. Ideal for users looking for quick, reliable, and efficient access to everyday functionalities.

---

## Getting Started
1. Install dependencies by running ```flutter pub get``` in the root folder of this project using the terminal.
2. The features included in this app are listed below:
    1. Login, Registration and Forgot Password flows
    2. Login Options - Email and Password / Mobile Number OTP
    3. Biometric
    4. Push Notifications
    5. Social Login
    6. Maps integration
    7. Permissions
    8. Change Password

### Maps integration setup
The Maps integration feature uses the custom ```flutter_google_maps``` package, the ```google_maps_flutter``` and ```geolocator``` packages.
1. In your ```AndroidManifest.xml``` file in ```android/app/src/main``` folder, add the following permissions inside the ```<manifest>``` tag:
```
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```
2. Then inside the ```<application>``` tag, add your Maps API Key:
```
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_MAPS_API_KEY"/>
```
3. In ```ios/Runner/AppDelegate.swift```, add the following lines:
```
import GoogleMaps
```
Inside the ```override func application(
    _ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool``` function, add:
```
GMSServices.provideAPIKey("YOUR_MAPS_API_KEY")
```
4. Inside ```ios/Runner/Info.plist```, add:
```
<key>NSLocationWhenInUseUsageDescription</key>
<string>YOUR_REASON_TO_ACCESS_LOCATION</string>
```

### Social login setup
This contains a simple screen that has buttons for Google Sign In and Facebook Sign In using the custom ```multi-auth``` package.

1. In your ```AndroidManifest.xml``` file in ```android/app/src/main``` folder, add the following permission inside the ```<manifest>``` tag:
```
<uses-permission android:name="android.permission.INTERNET"/>
```
2. Then inside the ```<application>``` tag, add your Google Cloud OAuth App Id. Add your Facebook App Id and Client tokens in your ```android/app/src/main/res/values/strings.xml``` file. If you don't already have a ```strings.xml``` file, create one in the path specified above.
```
<meta-data android:name="com.google.android.gms.appstate.APP_ID" android:value="YOUR_APP_ID" />
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
```

```
<!-- Strings.xml -->
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="facebook_app_id">YOUR_APP_ID</string>
    <string name="facebook_client_token">YOUR_CLIENT_TOKEN</string>
</resources>
```
3. Inside the ```<manifest>``` tag, add
```
<queries>
    <provider android:authorities="com.facebook.katana.provider.PlatformProvider" />
</queries>
```
4. In your ```ios/Runner/Info.plist``` file, add the following code:
```
    <key>GIDClientID</key>
    <string>YOUR_GOOGLE_OAUTH_CLIENT_ID</string>
    <key>CFBundleURLTypes</key>
    <array>
      <dict>
        <key>CFBundleURLSchemes</key>
        <array>
          <string>YOUR_GOOGLE_OAUTH_CLIENT_ID_IN_REVERSE_URL_SCHEME</string>
          <string>fb{YOUR_FACEBOOK_APP_ID}</string>
        </array>
      </dict>
    </array>
    <key>FacebookAppID</key>
    <string>YOUR_FACEBOOK_APP_ID</string>
    <key>FacebookClientToken</key>
    <string>YOUR_FACEBOOK_CLIENT_TOKEN</string>
    <key>FacebookDisplayName</key>
    <string>Frequent Flow</string>
    <key>LSApplicationQueriesSchemes</key>
    <array>
      <string>fbapi</string>
      <string>fb-messenger-share-api</string>
    </array>
```

### Permissions setup
The permissions uses a custom ```flutter_permissions``` package built on top of the ```permission_handler``` package.

1. List out the permissions required by the app in the ```AndroidMainifest.xml``` file.
```
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.WRITE_CONTACTS" />
```
2. In your ```Podfile``` inside the ios folder, add the below code based on the permissions you require:
```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
              '$(inherited)',
              'PERMISSION_CONTACTS=1',
              'PERMISSION_CAMERA=1',
              'PERMISSION_MICROPHONE=1',
              'PERMISSION_LOCATION=1',
              'PERMISSION_LOCATION_WHENINUSE=0',
              'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```
3. Add the required permission strings in your ```Info.plist``` file.
```
    <key>NSCameraUsageDescription</key>
    <string>We need access to your camera to capture photos and videos.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need access to your microphone to record audio.</string>
    <key>NSContactsUsageDescription</key>
    <string>We need access to your contacts to enhance your experience by syncing your data.</string>
```

### Push notifications
1. Setup Firebase Cloud Messaging by following the instructions in  https://firebase.google.com/docs/cloud-messaging/flutter/client

### Biometrics screen
Follow setup instructions for ```local_auth``` package using  https://pub.dev/packages/local_auth