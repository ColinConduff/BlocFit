# BlocFit

[![Download BlocFit on the App Store](http://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg)](https://itunes.apple.com/ca/app/blocfit/id1175156670)

BlocFit is a social run-tracking fitness game.

It includes integration with Facebook, Google Maps, GameKit, HealthKit, and the Multipeer Connectivity framework.  
The Multipeer Connectivity framework is used to enable peer-to-peer communication between runners.  
It also uses Core Data and Core Location.  

Feel free to send me feedback at colin.conduff@mst.edu.

BlocFit is available for free on the [App Store](https://itunes.apple.com/ca/app/blocfit/id1175156670).


## Setup

1.  Clone this repository  
  a.  `git clone https://github.com/ColinConduff/BlocFit.git`  
2.  Google Maps API Key  
  a.  Obtain an API key for [Google Maps](https://developers.google.com/maps/documentation/ios-sdk/start)  
  b.  `cp .env.example .env`  
  c.  add Google Maps API Key to .env file  
3.  Facebook App ID  
  a.  Obtain an App ID for [Facebook](https://developers.facebook.com/docs/ios/getting-started/)  
  b.  Create a file named fb.xcconfig containing the Facebook App ID.  
      `echo "FACEBOOK_APP_ID = <Insert-APP-ID>" > fb.xcconfig`  
4.  Install App Dependencies
  a.  `gem install bundler`
  b.  `bundle install`
  c.  `pod install`

The following prompt may appear (may be ignored if .env is provided):   
`What is the key for googleMapsAPIKey`  

5.  Open `BlocFit.xcworkspace` in Xcode   

## Troubleshooting

Follow the Google Maps SDK installation guide  
[Guide](https://developers.google.com/maps/documentation/ios-sdk/start)  
  
Follow the Facebook SDK installation guide  
[Guide](https://developers.facebook.com/docs/ios/getting-started/)  


## License

The source code to BlocFit is available under the MIT license. See the `LICENSE` file for more information.

Do not submit your own version of BlocFit to the App Store.


## Contact Information

Colin Conduff 
cconduff098@gmail.com or colin.conduff@mst.edu
