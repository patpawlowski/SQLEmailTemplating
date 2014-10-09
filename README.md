SQLEmailTemplating
==================

Sending emails from SQL using external HTML files as templates

The process isn't that complex but the beauty of it is that it allows a designer to manage the email templates as HTML files in a folder somewhere without ever needing to get invoved with the SQL. On the same note the DBA can manage the SQL processes without the hassle of keeping tabs on the templates. 

Two files included
- GM_SendEmail.sql which is an example SQL stored procedure that queries a database, imports the template into a variable, fills out the template, and ultimatel sends the email.
- Facebook Requested Email.htm which is an example email template stored as an HTML file on the file system. 
