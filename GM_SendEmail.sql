

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Written by:		Patrick Pawlowski, Ticomix, Inc.
	Created On:		2014-10-09 09:49:41.597
	Modified:		
	
	Description:	Example stored procedure to send an email from SQL using an external HTML template. 
					This example is configured to run against a GoldMine demo database with a Contacts view
					but it can be easily modifed to work against any SQL database. 

	Execution:		
	
					Exec GM_SendEmail @AccountNo = '94081300000303783Art', @Debug = 1
					
*/
Create procedure [dbo].[GM_SendEmail]
@AccountNo varchar(20),
@Debug int = 0
as

--Initialize debuging code
	Set nocount on
	If @Debug > 0 set @Debug = @Debug + 1
	Declare @DebugTxt varchar(100);set @DebugTxt = space(@Debug*2) + '{' + OBJECT_NAME(@@PROCID) + '}'
	Declare @ProcedureName varchar(100) = OBJECT_NAME(@@PROCID)
	If @Debug > 0 print @DebugTxt + ' starting'
	
--Declare some variables
	Declare @Contact varchar(40)
	Declare @Address varchar(40)
	Declare @City varchar(30)
	Declare @State varchar(20)
	Declare @Zip varchar(10)
	Declare @Phone varchar(25)
	Declare @EamilSubject varchar(100) = 'Facebook Web Lead '
	Declare @EmailBody varchar(max)
	Declare @EmailAddress varchar(75)
	Declare @DebugText varchar(max)
	Declare @CCRecipients varchar(1000)
	Declare @BCCRecipients varchar(1000)
	Declare @ToRecipients varchar(1000)

--Gather some data
	Select	
			@Contact = CONTACT,
			@Address = ADDRESS1,
			@City = CITY,
			@State = STATE,
			@Zip = ZIP,
			@Phone = PHONE1,
			@EmailAddress = EmailAddress
		from 
			Contacts 
		where 
			ACCOUNTNO = @AccountNo


--Get the email addresses to send to. 
--You would most likely not hard code these but pull them dynamically from somewhere. 
	Set @ToRecipients = 'JohnDough@patpawlowski.com'
	Set @CCRecipients = 'JaneDough@patpawlowski.com'
	Set @BCCRecipients = 'JimmyDough@patpawlowski.com'

-- Import the email template from file
	Select @EmailBody=BulkColumn
		from OPENROWSET(BULK'C:\EmailTemplates\Facebook Requested Email.htm',SINGLE_BLOB) x;

--Fill out the template
	Set @EmailBody = REPLACE(@EmailBody,'{Contact}',ISNULL(@Contact,''))
	Set @EmailBody = REPLACE(@EmailBody,'{Address}',ISNULL(@Address,''))
	Set @EmailBody = REPLACE(@EmailBody,'{City}',ISNULL(@City,''))
	Set @EmailBody = REPLACE(@EmailBody,'{State}',ISNULL(@State,''))
	Set @EmailBody = REPLACE(@EmailBody,'{Zip}',ISNULL(@Zip,''))
	Set @EmailBody = REPLACE(@EmailBody,'{Phone}',ISNULL(@Phone,''))
	Set @EmailBody = REPLACE(@EmailBody,'{EmailAddress}',ISNULL(@EmailAddress,''))
	Set @EmailBody = REPLACE(@EmailBody,'{TimeSent}',ISNULL(convert(varchar(50), current_timestamp, 20),''))

--Change some stuff it in debug
	If @Debug > 0 begin
		Set @DebugText = '<hr />This line and everything below it only appears in debug mode<hr />
							To:<br />'+ REPLACE(isnull(@ToRecipients,'NULL'),';','<br />') + '<br />
							CC:<br />'+ REPLACE(isnull(@CCRecipients,'NULL'),';','<br />') + '<br />
							BCC:<br />'+ REPLACE(isnull(@BCCRecipients,'NULL'),';','<br />') + '<br />'
		Print @ToRecipients
		Print @CCRecipients
		Print @BCCRecipients
		Print @EmailBody
		Set @ToRecipients = 'patpawlowski2001@gmail.com'
		Set @CCRecipients = ''
		Set @BCCRecipients = ''
	End

--Insert the debugging text into the template. 
--If debug is off then @DebugText will be null and this will simply remove the tag from the email.
	Set @EmailBody = REPLACE(@EmailBody,'{DebugText}',ISNULL(@DebugText,''))

--Send the email
	Exec msdb.dbo.sp_send_dbmail 
		@from_address = 'DoNotRespond@patpawlowski.com', 
		@reply_to = 'DoNotRespond@patpawlowski.com', 
		@recipients= @ToRecipients, 
		@copy_recipients = @CCRecipients,
		@blind_copy_recipients = @BCCRecipients,
		@body= @EmailBody,  
		@subject = @EamilSubject, 
		@profile_name = 'Default', 
		@body_format='HTML'

--Finalize debuging code
	If @Debug > 0 print @DebugTxt + ' finished'
	

