# Alibaba Page Parser
This is a simple Ruby on Rails application that allows users to parse product pages from Alibaba. It uses Turbo Streams to provide a Single Page Application (SPA) experience.

Features
* User Authentication: Only authenticated users can use the application. If a user is not signed in, they will be redirected to the sign in page with an alert message.
* Page Parsing: Users can enter a URL of a product page from Alibaba. The application will parse the page and display the product details.
* Currency Conversion: The application fetches the current currency rate from monobank and uses it to convert the product prices.
* Translation: data translated to Ukrainian language

![image](https://github.com/dafeys/aliparser/assets/36037839/d1b83c70-cd8e-4d7c-97d6-bd30c1274a5d)

![image](https://github.com/dafeys/aliparser/assets/36037839/00bac35e-7c9c-41cf-9b0b-626854365ea6)

Installation
* Clone the repository to your local machine.
* Navigate to the project directory.
* Run bundle install to install the required Ruby gems.
* Run rails assets:precompile to compile the assets.
* U need to have BrowserMob Proxy. This is used by the PageParserService to parse the Alibaba product pages with custom headers via selenium
* Run bin/dev to start the application.
