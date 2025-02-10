# Crop Shop

## Project ER 

![Screenshot 2024-10-22 at 7 02 15 PM (1)](https://github.com/user-attachments/assets/8551f81b-48a2-42c6-96f3-b484bbf4047f)



## Project DataFlow


![IMG_8079 (1)](https://github.com/user-attachments/assets/d1789306-bfd8-42ef-8a95-5b9b01ded898)


## Setup Guide
1 - Login as Admin to setup an admin account for the project 

User name : ADMIN,
Password : your_password

 - `Execute admin_setup.sql`
Admin account created
   
2 - Login as project admin to setup the table, roles & users

User name : hydro_admin,
Password : NeuBoston2024#

 - `Execute user_creation.sql`
 - `Execute admin_setup.sql`
 - `Execute create_tables.sql`
 - `Execute stored_procedures.sql`
All roles and user accounts created along with tables , relationship constraints & custom buisiness contstraints.
 
## Crop growth simulations
As a project admin they setup the Greenhouses & Plant Beds.
3 - Stay logged in as project admin to insert admin related data. 
 - `Execute insert_admin_data.sql` 
4- To simulate the entire data insertion process please run.
   - `Execute project_simulation.sql` 

## View Reports
7 - To create views, Log back in as admin, 

User name : hydro_admin,
Password : NeuBoston2024#
`Execute reports.sql`  
