import 'package:etmm/const/const.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kgrey,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
            color: kwhite,
          ),
        ),
        backgroundColor: themecolor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Introduction Section
          SectionTitle(title: "Welcome to Expense Tracker App"),
          SectionContent(
            content: "Expense Tracker is more than just an app; it's your personal finance companion. "
                "Our platform is designed to simplify expense tracking and management, ensuring that you can "
                "focus on what truly matters. Whether you’re a business Admin overseeing operations or an Employee "
                "managing day-to-day expenses, Expense Tracker has everything you need to stay on top of your finances. "
                "With a user-friendly interface, secure storage, and real-time tracking, this app makes managing money "
                "effortless and efficient.",
          ),

          // Admin Features Section
          /*SectionTitle(title: "Admin Features:"),
          SectionContent(
            content: "- **Create and Manage Expenses**: Admins can add detailed expenses with titles, amounts, payment modes, remarks, and even upload bills for better record-keeping.\n"
                "- **Manage Employees**: Seamlessly add, edit, or deactivate employees while keeping their profiles updated with vital details like email, mobile number, and status.\n"
                "- **Expense Categories Management**: Customize categories to suit your needs, whether it’s for personal use or your company. Categories such as Food, Fuel, and Salary ensure that every expense is well-organized.\n"
                "- **Expense Filters**: Quickly sort expenses by amount, date, or category to gain meaningful insights and make informed financial decisions.\n"
                "- **Download Expense Reports**: Generate professional **PDF** and **Excel** reports to keep track of spending trends and simplify audits.\n"
                "- **Security and Profile Management**: Keep your app secure with a custom PIN, update your profile with ease, and personalize your account settings.\n"
                "- **Geo-Location Tracking**: Monitor employee expenses with exact latitude, longitude, and location data to ensure accountability.\n"
                "- **App Settings**: Full control over app settings, including auto-approval for expenses, customizable labels, and visibility of date pickers or delete buttons for employees.",
          ),

          // Employee Features Section
          SectionTitle(title: "Employee Features:"),
          SectionContent(
            content: "- **Add Expenses**: Employees can log their expenses effortlessly, attach bill images, and categorize them for better tracking.\n"
                "- **Manage Profile**: Edit profile details, change passwords, and set a secure PIN to protect your data.\n"
                "- **Expense List by Categories**: Stay organized with categorized expense lists, helping you see exactly where your money is going.\n"
                "- **Expense Filters**: Analyze expenses by applying filters like month-wise breakdowns, amount ranges, or dates.\n"
                "- **Company Details Announcement**: New employees installing the app via referral links are greeted with Admin’s company details for a personalized experience.",
          ),

          // Upcoming Features Section
          SectionTitle(title: "Upcoming Features:"),
          SectionContent(
            content: "- **Referral Program**: Soon, Admins will be able to share a unique referral link with employees. When the app is installed using this link, employees will see their Admin’s company logo, name, and email, along with a direct login screen. This feature strengthens communication and simplifies onboarding.\n",
          ),*/

          SectionTitle(title: "Admin Features:"),
          SectionContent(
            content: "- Create and Manage Expenses\n"
                "- Manage Employees\n"
                "- Expense Categories Management\n"
                "- Expense Filters\n"
                "- Download Expense Reports\n"
                "- Security and Profile Management\n"
                "- Geo-Location Tracking\n"
                "- App Settings\n",
          ),

          // Employee Features Section
          SectionTitle(title: "Employee Features:"),
          SectionContent(
            content: "- Add Expenses\n"
                "- Manage Profile\n"
                "- Expense List by Categories\n"
                "- Expense Filters\n"
                "- Company Details Announcement\n",
          ),

          // Upcoming Features Section
          SectionTitle(title: "Upcoming Features:"),
          SectionContent(
            content:
                "- Referral Program: Admins will share referral links, and employees will be greeted with company details when they install the app via the link.\n",
          ),

          // Final Section
          SectionTitle(title: "Our Mission"),
          SectionContent(
            content:
                "At Expense Tracker, our mission is to empower individuals and organizations with tools that simplify expense management. "
                "We aim to create a seamless experience that combines innovation, security, and ease of use. "
                "Whether you're an Admin managing a team or an Employee tracking your day-to-day finances, our app ensures that "
                "every step of the process is intuitive and stress-free. Trust us to make financial tracking as easy as a few taps on your device.",
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: themecolor,
        ),
      ),
    );
  }
}

class SectionContent extends StatelessWidget {
  final String content;

  const SectionContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/*return Scaffold(
      backgroundColor: kgrey,
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Inter', color: kwhite),),
        backgroundColor: themecolor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Introduction Section
          SectionTitle(title: "Welcome to Expense Tracker App"),
          SectionContent(
            content: "Welcome to Expense Tracker, your one-stop solution for efficient expense management. "
                "Whether you’re an Admin or an Employee, our app offers a comprehensive suite of features to streamline your financial tracking.",
          ),

          // Admin Features Section
          SectionTitle(title: "Admin Features:"),
          SectionContent(
            content: "- Create and Manage Expenses\n"
                "- Manage Employees\n"
                "- Expense Categories Management\n"
                "- Expense Filters\n"
                "- Download Expense Reports\n"
                "- Security and Profile Management\n"
                "- Geo-Location Tracking\n"
                "- App Settings\n",
          ),

          // Employee Features Section
          SectionTitle(title: "Employee Features:"),
          SectionContent(
            content: "- Add Expenses\n"
                "- Manage Profile\n"
                "- Expense List by Categories\n"
                "- Expense Filters\n"
                "- Company Details Announcement\n",
          ),

          // Upcoming Features Section
          SectionTitle(title: "Upcoming Features:"),
          SectionContent(
            content: "- Referral Program: Admins will share referral links, and employees will be greeted with company details when they install the app via the link.\n",
          ),

          // Final Section
          SectionTitle(title: "Our Mission"),
          SectionContent(
            content: "Our mission is to provide a secure, organized, and intuitive platform to manage all aspects of your expenses. "
                "Whether you're tracking personal spending or managing company finances, Expense Tracker offers you a seamless and comprehensive solution.",
          ),
        ],
      ),
    );*/
