# Project Proposal: MySaveFood
Mobile Application Development Group Project

## a) Group Members
| Name | Matric Number | Responsibility |
| :--- | :--- | :--- |
| **ABDULLAH HARIS BIN ABDUL RASHID** | 2212901 | [e.g., UI/UX Design, Frontend Logic] |
| **MUHAMMAD MUIZZUDDIN BIN AMIN** | 2220323 | [e.g., Firebase Integration, Authentication] |
| **MOHAMAD NUR HAKIMI BIN ASMADI** | 2213091 | [e.g., State Management, Architecture] |

## b) Project Title
**MySaveFood**

## c) Introduction
### Problem Statement
Food waste is a critical issue in university campus environments. Cafeterias often dispose of edible food at the end of the day because they cannot sell it, while many students struggle with budgeting for meals. There is a disconnect between surplus food providers and those in need.

### Motivation
Our motivation is to bridge this gap using mobile technology. By creating a real-time platform, we can reduce food wastage and simultaneously support student welfare.

### Relevance
This project aligns with the **Social Welfare & NGO** and **Productivity/Utilities** domains, while strictly adhering to the **Shariah-compliant** requirement. It integrates global sustainability goals with Islamic ethical frameworks:

**1. UN Sustainable Development Goals (SDGs)**
* **Goal 2 (Zero Hunger):** Directly addresses student hunger by redistributing surplus food to those in need.
* **Goal 12 (Responsible Consumption and Production):** Tackles the issue of food waste at the source (cafeterias), promoting a sustainable consumption cycle on campus.

**2. Alignment with IIUM’s Tawhidic Epistemology**
* **Khilafah (Vicegerency):** As stewards of the earth, humans are entrusted to manage resources responsibly. Wasting food contradicts the role of a *Khalifah*. This app empowers users to fulfill this duty by preventing waste (*Israf*).
* **Maqasid Shariah (Objectives of Islamic Law):** The app supports the **Preservation of Life (*Hifz al-Nafs*)** by providing nutrition to students and the **Preservation of Wealth (*Hifz al-Mal*)** by ensuring economic resources (food value) are utilized rather than discarded.
* **Ukhuwah (Brotherhood):** It fosters a spirit of community care and charity (*Sadaqah*) within the university ecosystem.

## d) Objectives
1. To develop a platform that allows cafeteria owners to broadcast availability of surplus or near-expiry food instantly.
2. To provide students with a real-time discovery tool to locate and claim free food on campus.
3. To implement a fair reservation system that prevents overcrowding and ensures food goes to those who claim it first.
4. To strictly observe Shariah-compliant values by ensuring all listed food is Halal and the platform promotes ethical sharing.

## e) Target Users
### 1. Donors (Cafe Owners/Staff)
* **Demographics:** Campus cafeteria operators and food stall owners.
* **Behavior:** Busy individuals who need a quick (under 30 seconds) way to list items before closing time.
* **Goal:** Clear inventory without throwing food away and contribute to CSR (Corporate Social Responsibility).

### 2. Receivers (Students)
* **Demographics:** University students, particularly those living on or near campus.
* **Behavior:** Tech-savvy, budget-conscious, often looking for meals during late hours or end-of-day.
* **Goal:** Access affordable (free) meals and reduce daily expenses.

## f) Features and Functionalities
### Core Modules
1.  **User Authentication:** Secure login/registration using Email or Google Sign-In (distinguishing between Donor and Student roles).
2.  **Food Feed (Home Screen):** A list of currently available food items displayed with photos, quantity, pickup location, and "Best Before" time.
3.  **Post Item (Donor):** A simple form for donors to snap a photo, add a description, and set the quantity of leftover food.
4.  **Claim System (Student):** A "Reserve" button that decrements the available quantity in real-time to prevent double-booking.
5.  **Notifications:** Push notifications to alert students when new food is posted near them.
6.  **Profile & History:** Users can view their past donations or claimed items.
7.  **Reporting & Moderation:** A dedicated feature allowing users to report suspicious activity, fake listings, or non-Halal food items. This ensures the platform remains safe and trusted.

### Shariah Compliance
* **Halal Verification:** All registered Donors must be Halal-certified vendors.
* **Ethical Usage:** The reporting system actively prevents abuse, ensuring the platform is used solely for genuine charitable purposes.

## g) Proposed UI Mock-up
![Login Screen Mockup](INSERT_IMAGE_LINK_HERE)
![Home Screen Mockup](INSERT_IMAGE_LINK_HERE)
![Post Item Mockup](INSERT_IMAGE_LINK_HERE)

> *The sketches above demonstrate the user-friendly layout and consistent color scheme planned for the final app.*

## h) Architecture / Technical Design
### Framework
We will use **Flutter** to ensure cross-platform compatibility (Android & iOS) and high performance.

### Widget Structure
* **StatelessWidgets:** For static UI elements (e.g., Headers, Info Cards).
* **StatefulWidgets:** For interactive forms (e.g., Post Food Form, Login Page).

### State Management
We will utilize **Provider** (or Riverpod) for state management. This will allow us to efficiently manage user authentication states and the real-time list of food items across the application without "prop drilling."

### Design Pattern
We will follow the **MVVM (Model-View-ViewModel)** architecture to separate the business logic (ViewModel) from the UI (View), ensuring the code is modular and testable.

## i) Data Model
We will use **Cloud Firestore** (NoSQL) for the database.

### Collections Structure

**1. `users` Collection**
* `uid` (String, PK)
* `name` (String)
* `role` (String: 'donor' or 'student')
* `email` (String)

**2. `food_items` Collection**
* `itemId` (String, PK)
* `donorId` (Reference to users)
* `imageUrl` (String - stored in Firebase Storage)
* `title` (String)
* `description` (String)
* `quantity` (Integer)
* `pickupLocation` (String)
* `expiryTime` (Timestamp)
* `status` (String: 'available', 'claimed')

**3. `claims` Collection**
* `claimId` (String, PK)
* `itemId` (Reference to food_items)
* `studentId` (Reference to users)
* `timestamp` (Timestamp)

## j) Flowchart / Sequence Diagram
![Sequence Diagram](INSERT_IMAGE_LINK_HERE)

> *The diagram above illustrates the sequence of a Donor posting an item, the item appearing on the Student's feed, and the Student successfully claiming the item, which updates the database in real-time.*

## k) References
1.  **Flutter Documentation:** https://flutter.dev/docs
2.  **Firebase Documentation:** https://firebase.google.com/docs
3.  **Provider Package:** https://pub.dev/packages/provider
4.  **Material Design Guidelines:** https://material.io/design
