# 🏥 MediVault — Your Lifelong Medical Record

<p align="center">
  <img src="assets/logo.png" alt="MediVault Logo" width="140"/>
</p>

<h3 align="center">
  A Patient-Centric AI-Powered Medical Record Management Application
</h3>

<p align="center">
  Securely store, organize, access, and understand your lifelong medical records in one place.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Mobile%20Application-blue?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Firebase-Authentication-orange?logo=firebase" alt="Firebase"/>
  <img src="https://img.shields.io/badge/AWS-S3-yellow?logo=amazonaws" alt="AWS S3"/>
  <img src="https://img.shields.io/badge/Google%20Vision-OCR-red?logo=google" alt="Google Vision"/>
  <img src="https://img.shields.io/badge/Gemini-2.0%20Flash-purple?logo=google" alt="Gemini"/>
</p>

---

## 📌 Overview

**MediVault** is a patient-centric mobile healthcare application designed to provide users with a centralized platform for managing their lifelong medical records.

The application allows users to securely upload and manage medical reports while using **OCR and Artificial Intelligence** to process uploaded documents.

MediVault integrates:

* 🔐 Firebase Authentication for secure user authentication
* ☁️ AWS S3 for medical document storage
* 🗄️ Cloud Firestore for user data and medical record metadata
* 🔎 Google Cloud Vision API for OCR
* 🤖 Google Gemini 2.0 Flash for AI-powered analysis and conversational assistance
* 📰 NewsAPI for healthcare news and updates
* 📱 Shared Preferences for locally storing emergency medical information

The system is designed to improve accessibility to medical records and help users understand complex medical information through AI-assisted explanations.

---

## 🎯 Problem Statement

Patients often have medical reports distributed across different hospitals, diagnostic centers, and healthcare providers.

This creates several problems:

* Difficulty maintaining lifelong medical records
* Dependency on physical documents
* Difficulty accessing previous medical history
* Repeated diagnostic tests when previous reports are unavailable
* Difficulty understanding complex medical terminology
* Limited patient ownership of healthcare records
* Lack of intelligent organization of medical documents

MediVault addresses these challenges by providing a unified, patient-focused platform for storing, organizing, accessing, and understanding medical records.

---

## 💡 Proposed Solution

MediVault provides a centralized mobile application where users can:

1. Create an account and securely log in.
2. Store medical reports digitally.
3. Upload PDF and image-based medical documents.
4. Store documents securely in AWS S3.
5. Store associated metadata in Cloud Firestore.
6. Extract text from reports using Google Vision OCR.
7. Automatically identify the relevant medical department using Gemini.
8. Organize records using a timeline-based interface.
9. Ask questions through an AI-powered medical assistant.
10. Access emergency medical information quickly, including during offline conditions.

The proposed system combines cloud computing, OCR, artificial intelligence, and mobile application technologies into a single healthcare platform.

---

# ✨ Key Features

### 🔐 Secure Authentication

Users can register and log in using their email and password through Firebase Authentication.

### 📂 Medical Record Management

Users can upload, view, edit, download, and manage their medical documents.

### ☁️ Cloud Storage

Medical files are stored using AWS S3, while metadata is maintained in Cloud Firestore.

### 🔎 OCR-Based Text Extraction

Google Cloud Vision API extracts text from uploaded medical reports.

### 🧠 Automatic Department Detection

The extracted medical text is processed by Google Gemini 2.0 Flash to identify the relevant medical department such as:

* Cardiology
* Neurology
* Orthopaedics
* Other relevant departments

The detected department is stored as metadata and displayed in the user's medical timeline.

### 🤖 AI Medical Assistant

The AI Chat feature provides a conversational interface where users can ask health-related questions and receive simplified, context-aware explanations.

The system supports:

* Multi-turn conversations
* Conversation history
* User profile context
* Simplified medical explanations
* Follow-up questions

### 🚨 Emergency Information

Critical medical information such as:

* Blood group
* Allergies
* Chronic conditions
* Medications
* Emergency contacts

can be stored locally using Shared Preferences.

This allows important information to remain accessible even without internet connectivity or before user authentication.

### 📰 Healthcare News

The home dashboard includes healthcare-related news retrieved using NewsAPI.

### 📱 Timeline-Based Records

Medical records are organized chronologically and categorized according to their detected medical department.

---

# 🏗️ System Architecture

```text
                         ┌─────────────────────┐
                         │       USER          │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │ Flutter Mobile App  │
                         └──────────┬──────────┘
                                    │
                 ┌──────────────────┼──────────────────┐
                 │                  │                  │
                 ▼                  ▼                  ▼
        ┌────────────────┐  ┌────────────────┐  ┌────────────────┐
        │ Firebase Auth  │  │ Cloud Firestore│  │  Shared Prefs  │
        └────────────────┘  └───────┬────────┘  └────────────────┘
                                    │
                                    │ Metadata
                                    ▼
                              ┌─────────────┐
                              │   AWS S3    │
                              │ File Storage│
                              └──────┬──────┘
                                     │
                                     │ Medical Document
                                     ▼
                           ┌─────────────────────┐
                           │ Google Cloud Vision │
                           │       OCR           │
                           └──────────┬──────────┘
                                      │
                                      │ Extracted Text
                                      ▼
                           ┌─────────────────────┐
                           │ Gemini 2.0 Flash    │
                           │ AI Processing       │
                           └──────────┬──────────┘
                                      │
                          ┌───────────┴───────────┐
                          │                       │
                          ▼                       ▼
                 Department Detection       AI Chat Assistant
                          │                       │
                          └───────────┬───────────┘
                                      ▼
                              ┌─────────────┐
                              │   MediVault │
                              │     App     │
                              └─────────────┘
```

The architecture follows a layered user-driven pipeline in which authentication, cloud storage, OCR, AI processing, metadata management, and local emergency information work together.

---

# 🔄 Application Workflow

## Medical Record Upload Workflow

```text
User selects PDF/Image
        │
        ▼
Flutter Application
        │
        ├──────────────► AWS S3
        │                 │
        │                 └── Secure File Storage
        │
        ├──────────────► Cloud Firestore
        │                 │
        │                 └── File Metadata
        │
        ▼
Google Cloud Vision API
        │
        ▼
OCR Text Extraction
        │
        ▼
Gemini 2.0 Flash
        │
        ▼
Department Detection
        │
        ▼
Firestore Metadata
        │
        ▼
Medical Timeline
```

The documentation specifies that uploaded PDF/image files are stored in AWS S3, metadata is stored in Firestore, OCR is performed using Google Vision, and extracted text is analyzed by Gemini for department detection.

---

# 🤖 AI Chat Workflow

```text
User opens AI Chat
        │
        ▼
Retrieve User Profile
        │
        ▼
Retrieve Conversation History
        │
        ▼
Build Gemini Prompt
        │
        ▼
Gemini 2.0 Flash
        │
        ▼
Context-Aware Response
        │
        ▼
Display Response
        │
        ▼
Continue Multi-Turn Conversation
```

The AI assistant uses the user's health profile as context and maintains conversation history to support multi-turn interactions.

---

# 🛠️ Technology Stack

| Layer           | Technology              | Purpose                                   |
| --------------- | ----------------------- | ----------------------------------------- |
| Mobile Frontend | Flutter                 | Cross-platform mobile application         |
| Authentication  | Firebase Authentication | Email/password authentication             |
| Database        | Cloud Firestore         | User profiles and medical record metadata |
| Cloud Storage   | AWS S3                  | Medical document storage                  |
| OCR             | Google Cloud Vision API | Text extraction from medical reports      |
| AI / LLM        | Google Gemini 2.0 Flash | Department detection and AI chat          |
| Healthcare News | NewsAPI                 | Healthcare news and updates               |
| Local Storage   | Shared Preferences      | Emergency medical information             |

These technologies and their roles are documented in the MediVault project documentation.

---

# 📱 Application Displays

The following screens represent the main user interface of the MediVault application.

> **Note:** Replace the image paths below with the actual screenshot filenames from your repository. The screenshots are displayed directly in this README; no separate README or documentation file is required.

---

## 1. Splash Screen

The Splash Screen is displayed when the application starts and presents the MediVault branding with the tagline **"Your Lifelong Medical Record."**

<p align="center">
  <img src="assets/screenshots/splash_screen.png" alt="MediVault Splash Screen" width="260"/>
</p>

---

## 2. Landing Page — Introduction

The first landing page introduces MediVault and explains its purpose of securely storing and organizing medical records in one centralized location.

<p align="center">
  <img src="assets/screenshots/landing_page_1.png" alt="MediVault Landing Page 1" width="260"/>
</p>

---

## 3. Landing Page — Emergency Information

The second landing page introduces the emergency medical information feature and highlights the availability of important health information during emergencies.

<p align="center">
  <img src="assets/screenshots/landing_page_2.png" alt="MediVault Landing Page 2" width="260"/>
</p>

---

## 4. Login & Signup

The authentication screen allows new users to create an account and existing users to log in using email and password.

Firebase Authentication is used to validate user credentials.

<p align="center">
  <img src="assets/screenshots/login_signup.png" alt="MediVault Login and Signup" width="260"/>
</p>

---

## 5. Home Dashboard

The Home Screen acts as the central dashboard of MediVault.

It provides:

* Welcome information
* Emergency information shortcut
* Profile access
* Monthly activity summary
* Record statistics
* Recent medical records
* Healthcare news
* Bottom navigation

<p align="center">
  <img src="assets/screenshots/home_screen.png" alt="MediVault Home Screen" width="260"/>
</p>

---

## 6. Emergency Information

The Emergency Information screen provides quick access to critical medical information.

<p align="center">
  <img src="assets/screenshots/emergency_information.png" alt="MediVault Emergency Information" width="260"/>
</p>

---

## 7. Emergency Contact & Medical Details

Users can maintain important emergency details such as medical information and emergency contacts.

<p align="center">
  <img src="assets/screenshots/emergency_details.png" alt="MediVault Emergency Details" width="260"/>
</p>

---

## 8. Record Upload

Users can select and upload medical documents in PDF or image format.

The uploaded document is stored in AWS S3 and simultaneously processed through Google Vision OCR.

<p align="center">
  <img src="assets/screenshots/record_upload.png" alt="MediVault Record Upload" width="260"/>
</p>

---

## 9. Record Uploaded Confirmation

After successful upload, MediVault displays a confirmation message.

The document is stored in AWS S3 while its metadata is stored in Cloud Firestore. OCR and AI-based department detection are then performed.

<p align="center">
  <img src="assets/screenshots/upload_success.png" alt="MediVault Upload Confirmation" width="260"/>
</p>

---

## 10. My Records

The My Records screen displays uploaded medical documents in a structured chronological timeline.

Each record can contain information such as:

* File name
* Upload date
* Detected medical department
* Document access options

Users can also perform actions such as viewing, downloading, editing, or deleting records.

<p align="center">
  <img src="assets/screenshots/my_records.png" alt="MediVault My Records" width="260"/>
</p>

---

## 11. Profile

The Profile screen displays user information and allows users to manage their personal account details.

<p align="center">
  <img src="assets/screenshots/profile.png" alt="MediVault Profile Screen" width="260"/>
</p>

---

## 12. Settings

The Settings screen provides options for:

* Profile management
* Emergency information
* Application configuration
* Account settings
* Logout

<p align="center">
  <img src="assets/screenshots/settings.png" alt="MediVault Settings Screen" width="260"/>
</p>

---

## 13. AI Chat

The AI Chat screen provides a conversational interface for understanding medical information.

Users can ask health-related questions and continue the conversation through multiple follow-up queries.

The system uses Gemini API to generate context-aware responses in a structured chat interface.

<p align="center">
  <img src="assets/screenshots/ai_chat.png" alt="MediVault AI Chat" width="260"/>
</p>

---

# 🧩 Core Modules

### Authentication Module

Responsible for:

* User registration
* User login
* Credential validation
* Secure access to user data

### Medical Record Module

Responsible for:

* Uploading medical reports
* Viewing records
* Editing records
* Downloading records
* Deleting records
* Timeline-based organization

### OCR Module

Responsible for extracting text from uploaded medical documents using Google Cloud Vision API.

### AI Processing Module

Responsible for:

* Medical department detection
* Medical report understanding
* AI-powered conversational assistance
* Simplified explanations

### Emergency Module

Responsible for storing and providing quick access to critical medical information.

### News Module

Fetches healthcare-related news using NewsAPI.

---

# 🔐 Security & Privacy

MediVault is designed with secure medical-data handling in mind.

Key security considerations include:

* Firebase Authentication for user authentication
* Cloud-based storage through AWS S3
* Firestore-based metadata management
* Controlled access to medical records
* Local storage of emergency information for quick access
* Separation of medical document storage and metadata

For a production deployment, additional security controls such as stricter Firestore security rules and secure backend API-key management should be implemented. These are also identified as future enhancements in the project documentation.

> **Important:** MediVault is an academic/project implementation and should not be treated as a substitute for professional medical diagnosis or treatment.

---

# 📊 Performance Metrics

The project documentation identifies the following metrics for evaluating MediVault:

| Metric                        | Description                                             |
| ----------------------------- | ------------------------------------------------------- |
| OCR Extraction Accuracy       | Accuracy of text extraction from medical documents      |
| Department Detection Accuracy | Correctness of AI-based department classification       |
| File Upload Success Rate      | Percentage of successfully uploaded files               |
| Application Response Time     | Time required for login, upload, OCR, and AI operations |
| Authentication Success Rate   | Reliability of authentication operations                |

---

# 📂 Suggested Project Structure

```text
MediVault/
│
├── android/
├── ios/
├── lib/
│   ├── screens/
│   ├── widgets/
│   ├── services/
│   ├── models/
│   └── utils/
│
├── assets/
│   ├── images/
│   └── screenshots/
│       ├── splash_screen.png
│       ├── landing_page_1.png
│       ├── landing_page_2.png
│       ├── login_signup.png
│       ├── home_screen.png
│       ├── emergency_information.png
│       ├── emergency_details.png
│       ├── record_upload.png
│       ├── upload_success.png
│       ├── my_records.png
│       ├── profile.png
│       ├── settings.png
│       └── ai_chat.png
│
├── test/
│
├── pubspec.yaml
├── README.md
└── LICENSE
```

> Update the folder names above to match the actual source-code structure of your repository if they differ.

---

# ⚙️ Installation & Setup

## Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* VS Code or Android Studio
* Git
* Firebase project
* AWS S3 configuration
* Google Cloud Vision API configuration
* Google Gemini API configuration
* NewsAPI configuration

---

## 1. Clone the Repository

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd MediVault
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Configure Firebase

Create a Firebase project and configure Firebase Authentication and Cloud Firestore.

Add the appropriate Firebase configuration files for your Flutter platform.

Do not commit private credentials or secrets to GitHub.

---

## 4. Configure AWS S3

Configure your AWS S3 storage according to the application's implementation.

The application uses S3 to securely store uploaded medical documents.

---

## 5. Configure Google Vision API

Enable Google Cloud Vision API and configure the required credentials.

The Vision API is responsible for OCR-based text extraction from uploaded medical reports.

---

## 6. Configure Gemini API

Configure the Gemini API using the Google Gemini 2.0 Flash model.

Gemini is used for:

* Medical department detection
* AI-powered chat
* Context-aware responses
* Simplified explanations

---

## 7. Configure NewsAPI

Configure the NewsAPI key used to retrieve healthcare-related news for the home dashboard.

---

## 8. Run the Application

Connect an Android device or start an Android emulator.

Then run:

```bash
flutter run
```

To check the Flutter environment:

```bash
flutter doctor
```

---

# 🧪 Testing

Run the Flutter test suite using:

```bash
flutter test
```

For static analysis:

```bash
flutter analyze
```

---

# 🔄 Complete Data Flow

```text
                 USER
                  │
                  ▼
          Flutter Mobile App
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
 Firebase Auth         Cloud Firestore
        │                   │
        │                   │
        └─────────┬─────────┘
                  │
                  ▼
          Medical Record
             Upload
                  │
          ┌───────┴────────┐
          │                │
          ▼                ▼
       AWS S3          Google Vision
     File Storage           OCR
                             │
                             ▼
                       Extracted Text
                             │
                             ▼
                      Gemini 2.0 Flash
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
             Department          AI Assistant
             Detection           Conversation
                    │                 │
                    └────────┬────────┘
                             ▼
                       User Dashboard
```

---

# 🚀 Future Enhancements

The project documentation identifies several possible future improvements:

* 🔐 Advanced Firestore security rules
* 🔑 Secure API-key management through backend proxy or secure storage
* 🌐 Multi-language AI explanations
* 👨‍⚕️ Doctor and family-member record sharing
* 📶 Offline access to previously uploaded medical records
* ⌚ Wearable health-device integration
* 🤖 Automated medical-report summarization
* 📱 Google Play Store deployment
* 🍎 iOS platform support
* 🏥 Hospital integration
* 🔔 Medication reminders and health alerts

---

# 📈 Project Impact

MediVault aims to improve healthcare record accessibility by providing users with a centralized platform for lifelong medical-document management.

The integration of OCR and AI reduces the effort required to organize medical reports, while the AI assistant helps users understand complex medical terminology in simpler language.

The emergency information module further improves accessibility by allowing critical information to be available locally even in offline scenarios.

---

# 🎓 Academic Context

**Project:** MediVault
**Domain:** Healthcare Technology / Mobile Application / Artificial Intelligence
**Platform:** Android
**Frontend Framework:** Flutter
**Database:** Firebase Cloud Firestore
**Authentication:** Firebase Authentication
**Cloud Storage:** AWS S3
**OCR:** Google Cloud Vision API
**AI Model:** Google Gemini 2.0 Flash
**News Service:** NewsAPI
**Local Storage:** Shared Preferences

---

# 📚 Documentation

The project documentation covers:

* Introduction
* Literature Review
* Proposed System
* System Architecture
* Methodology
* Algorithms
* Application Screens
* Results and Analysis
* Conclusion
* Future Scope
* References

The application screens documented in the project include Splash, Landing, Login/Signup, Home, Emergency Information, Emergency Details, Record Upload, Upload Confirmation, My Records, Profile, Settings, and AI Chat.

---

# ⚠️ Disclaimer

MediVault is developed as an academic/project application for managing and understanding personal medical records.

The AI-generated information provided by the application is intended for informational purposes only and should **not** be considered a medical diagnosis, prescription, or replacement for professional healthcare advice.

Users should consult qualified healthcare professionals for medical decisions.

---

# 🤝 Contributing

Contributions are welcome.

To contribute:

```bash
# Fork the repository

# Create a feature branch
git checkout -b feature/your-feature

# Make your changes

# Commit your changes
git commit -m "Add: your feature"

# Push the branch
git push origin feature/your-feature
```

Then open a Pull Request describing the changes.

---

# 📄 License

This project is intended for academic and educational purposes.

If a specific open-source license is added to the repository, replace this section with the corresponding license information.

---

# 👩‍💻 Authors

**MediVault Development Team**

Developed as a project focused on combining:

**Mobile Development + Cloud Computing + OCR + Artificial Intelligence + Healthcare**

---

<p align="center">

### 🏥 MediVault

**Your Lifelong Medical Record**

*Store. Organize. Understand. Access.*

</p>
