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
 - `Execute admin_setup.sql`
 - `Execute create_tables.sql`
 - `Execute stored_procedures.sql`
All roles and user accounts created along with tables , relationship constraints & custom buisiness contstraints.
 
## Data Creation
As a project admin they setup the Greenhouses & Plant Beds.
3 - Stay logged in as project admin to insert admin related data. 
 - `Execute insert_admin_data.sql` 
4- To simulate the entire data insertion process please run.
   - `Execute project_simulation.sql` 

## View Creation 
7 - To create views, Log back in as admin, 

User name : hydro_admin,
Password : NeuBoston2024#

 - `Execute reports.sql`

### Notes
- Only for plant bed 1  the sensor logs have been inserted ( 20 rows) for view purposes.
- Go through steps 1 - 7 sequentially to avoid missing parent key errors.
- Files `user_creation.sql` ,`create_tables.sql`, `admin_setup.sql` have clean up scripts and can be rerun.
- To rerun anytime after `user_creation.sql` just in case `Execute drop user hydro_admin cascade`
  
Thank You. 

Team 17  - Saaketh Ch , Satwika M , Likhith NG
