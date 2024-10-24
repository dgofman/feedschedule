# feedschedule

A new Flutter project for managing feeding schedules.

# Initialize Project

flutter create --project-name feedschedule -t app .

flutter run --release

## Getting Started

Follow these steps to set up the project:

1. **Create a Firebase Project**: Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. **Create Apps**: Set up Android and/or iOS apps. For guidance, watch [this video](https://www.youtube.com/watch?v=FYcYVkTowRs).
3. **Download Configuration Files**:
    - For Android, save the `google-services.json` file into `android/app/`.
    - For iOS, save the `GoogleService-Info.plist` file into `ios/Runner/`.
4. **Choose Product Categories**: Select "Firestore Database" in the Firebase project settings.
5. **Create Users Collection**: Under Firestore, create a collection named "users" and add a document with the following fields:
    - **id** (type: string)
6. **Set Firestore Rules**: Navigate to the Rules tab and add the following rules for your collections:
   ```plaintext
   rules_version = '2';

   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{id} {
         allow read: if true;
       }
       match /feeding/{id} {
         allow read, write: if true;
       }
       match /events/{id} {
         allow read, write: if true;
       }
       match /schedule/{id} {
         allow read, write: if true;
       }
     }
   }


## Meta Business Suite Setup

1. Go to Facebook Developers. https://developers.facebook.com/
2. Click on "My Apps" or "Get Started" to register.
3. Click "Create App".
4. Choose not to connect a business portfolio yet.
5. Click Next
6. Select "Other" and Next.
7. Choose "Business" and Next.
8. Enter the App Name: Feed Schedule
9. Click Next, click Create app
10. On the dashboard, navigate to WhatsApp and click "Set up".
11. If you encounter an error, visit Facebook Business to create a new business portfolio.
    (https://business.facebook.com/ and create new Business portfolio)
12. Add your phone number and verify it.
13. Click "Send Message" to complete the setup.

## Setup IOs

https://firebase.google.com/docs/flutter/setup?platform=ios

Troubleshoot:

1. cd ios
2. open Podfile  (or open ios/Podfile)
3. Add line on the top:
   ```plaintext
   platform :ios, '12.0'
   source 'https://github.com/CocoaPods/Specs.git'
   ```
And

   ```plaintext
   target 'Runner' do
      use_frameworks! :linkage => :static  # Add this line
      flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
   ```
4. rm -rf ~/.cocoapods
5. pod deintegrate
6. pod install --verbose
   Note: You can start a clone process from another window
   ```plaintext
    Ctrl +C
    cd ~/.cocoapods/repos
    git clone --depth 1 https://github.com/CocoaPods/Specs.git master
