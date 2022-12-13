# fabric-agency

## Technology
- For the techstack, we used **NodeJS** with **Express** and template engine **HandlebarsJS** to handle requests between Frontend and Backend. For database, we use **Oracle Database**.

## Run the project locally
### Setup database
Users have to create new user in MongoDB with username of **Manager** and run the sql script in the source code in **SQL Developer** to create database schemas and constraints.

### Prerequisites
Make sure your devices has the latest version of **npm** and **Oracle Database**
### Clone the repository
```{bash}
https://github.com/DB221/fabric-agency.git
```
### Go to the project directory and install the requirements
In this step, you need to install packages for the application
```{bash}
cd fabric-agency
npm install
```

### Start the app
To run the app, simply run the statement:
```{bash}
npm start
```
User will be prompted to the login page where they should log in with their **Manager** account in **Oracle Database**. After logging in, user can use the application to view information about the Fabric Agency.
