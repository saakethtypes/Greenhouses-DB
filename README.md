# DMDD-project-team_17

# Steps to Execute 
## Project Setup
1 - Login as Admin to setup an admin account for the project 

User name : ADMIN,
Password : your_password

 - `Execute admin_setup.sql`
Admin account created
   
2 - Login as project admin to setup the table, roles & users

User name : hydro_admin,
Password : NeuBoston2024#

 - `Execute user_creation.sql`
 - `Execute create_tables.sql`
 - `Execute role_grants.sql`
All roles and user accounts created along with tables , relationship constraints & custom buisiness contstraints.
 
## Data Creation
As a project admin they setup the Greenhouses & Plant Beds.
3 - Stay logged in as project admin to insert admin related data. 
 - `Execute insert_admin_data.sql` 

4 - Log out of admin account and log in to Agronomist. They setup the Growth Cycles, Crop Types & Harvest Crops. 

User name: hydro_agronomist 
Password: Agripassword20#

 - `Execute insert_agronomist_data.sql`

5 - Log out of agronomist account and log in to Technician. They gather data from the sensors & Sensor Logs. 

User name :hydro_technician 
Password :Techpassword20#

 - `Execute insert_technician_data.sql`

6 - Log out of technician account and log in as any customer. Populating Customers and orders 

User name : hydro_sales_manager,
Password :Salespassword20#

 - `Execute insert_customers_data.sql`

## View Creation 
7 - To create views, Log back in as admin, 

User name : hydro_admin,
Password : NeuBoston2024#

 - `Execute create_views.sql`

### Notes
- Only for plant bed 1  the sensor logs have been inserted ( 20 rows) for view purposes.
- Go through steps 1 - 7 sequentially to avoid missing parent key errors.
- Files `user_creation.sql` ,`create_tables.sql`, `admin_setup.sql` have clean up scripts and can be rerun.
- To rerun anytime after `user_creation.sql` just in case `Execute drop user hydro_admin cascade`
  
Thank You. 

Team 17  - Saaketh Ch , Satwika M , Likhith NG
