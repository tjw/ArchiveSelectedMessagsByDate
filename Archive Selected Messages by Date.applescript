
set ShouldProcessUnreadMessages to false

--
--
--

on MailboxNameForMessage(msg)
	tell application "Mail"
		-- Default to a date based archive
		-- Build a mailbox name of "Archive/YYYY/MM"
		set MyDate to date received of msg
		set MyYear to year of MyDate
		set MyMonth to month of MyDate as integer
		if MyMonth is less than 10 then
			set MyMonth to "0" & (MyMonth as string)
		end if
		return "Archive/" & (MyYear as string) & "/" & (MyMonth as string)
	end tell
end MailboxNameForMessage

on MailboxForMessage(msg)
	tell application "Mail"
		set MyMailboxName to my MailboxNameForMessage(msg)
		
		-- Get the archive mailbox in the same account, creating it if it isn't there
		set DestAccount to account of mailbox of msg
		
		try
			log "getting mailbox"
			set DestMailbox to mailbox MyMailboxName of DestAccount
		on error
			try
				tell DestAccount
					log "creating mailbox"
					set DestMailbox to make new mailbox with properties {name:MyMailboxName}
				end tell
			on error
				-- On the first of the month, one machine will create the mailbox and others will not see it.
				log "look up mailbox again"
				synchronize with DestAccount
				set DestMailbox to mailbox MyMailboxName of DestAccount
				if DestMailbox is missing value then
					log "Ooops"
				end if
			end try
		end try
		
		return DestMailbox
	end tell
end MailboxForMessage

tell application "Mail"
	set MyMessages to selection
	
	repeat with MyMessage in MyMessages
		-- Don't archive unread messages
		if ShouldProcessUnreadMessages or (read status of MyMessage is true) then
			
			-- Figure out where to put the message and do so			
			set DestMailbox to my MailboxForMessage(MyMessage)
			if DestMailbox is not missing value then
				set mailbox of MyMessage to DestMailbox
			end if
		end if
	end repeat
end tell
