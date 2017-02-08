#customer-service/tcl/cs-biz-procs.tcl
ad_library {

    business procs for customer-service
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}

ad_proc -public cs_ticket_create {
    args
} {
    Create a ticket. Returns ticket_id. 
    If ticket_ref_name is defined, assigns the variable name of ticket_ref_name to the ticket's external reference.
    <br/>
    args: 
    customer_id authenticated_by ticket_category_id current_tier_level subject ignore_reopen_p unscheduled_service_req_p scheduled_operation_p scheduled_maint_req_p priority
    <br/>
    See c_tickets table definition for usage.
} {
    upvar 1 instance_id instance_id

    set p [list \
               ticket_id \
               ticket_ref_name \
               customer_id \
               authenticated_by \
               ticket_category_id \
               current_tier_level \
               subject \
               cs_open_p \
               ignore_reopen_p \
               unsecheduled_service_req_p \
               scheduled_operation_p \
               scheduled_maint_req_p \
               priority \
               ticket_ref_name ]

    qf_nv_list_to_vars $args $p
    
    if { $ticket_ref_name ne "" && [hf_list_filter_by_alphanum [list $ticket_ref_name]] } {
        upvar 1 $ticket_ref_name ticket_ref
    }
    set trashed_p 0
    if { $privacy_level eq "" } {
        set package_id [ad_conn package_id]
        set privacy_level [parameter::get -parameter privacyLevel -package_id $package_id]
    }               
    if { $ignore_reopen_p eq "" } {
        set package_id [ad_conn package_id]
        set ignore_reopen_p [parameter::get -parameter ignoreReopenP -package_id $package_id]
    }               
    
    # init new ticket, open,
    set user_id [ad_conn user_id]
    set cs_opened_by $user_id
    
    # defaults to %Y-%m-%d %H:%M:%S
    set cs_time_opened [dt_systime]
    set user_open_p 1
    set user_time_opened $cs_time_opened
         
    set ticket_id [cs_id_seq_nextval ticket_ref]
    #set ticket_ref  --corresponds to ticket_id

## code   This comment gets moved to adp/tcl page:
# if !$tickets.unscheduled_service_req_p
#  ask customer when is preferred service time (in the first created message).
#  in case of service interruptions are needed.
#  and ask when is most important that interruptions are minimized.
    ns_log Notice "cs_ticket_create ticket_id '${ticket_id}' by user_id '${user_id}'"
    db_dml cs_tickets_cr {insert into cs_tickets
        (ticket_id,instance_id,customer_id,authenticated_by,ticket_category_id,
         current_tier_level,subject,cs_open_p,opened_by,cs_time_opened,
         user_open_p,user_time_opened,privacy_level,trashed_p,
         ignore_reopen_p,unscheduled_service_req_p,scheduled_operation_p,
         scheduled_maint_req_p,priority)
        values (:ticket_id,:instance_id,:customer_id,:authenticated_by,:ticket_category_id,
         :current_tier_level,:subject,:cs_open_p,:opened_by,:cs_time_opened,
         :user_open_p,:user_time_opened,:privacy_level,:trashed_p,
         :ignore_reopen_p,:unscheduled_service_req_p,:scheduled_operation_p,
         :scheduled_maint_req_p,:priority)
    }
    # cs_ticket_message_create

##code
                
# if $tickets.scheduled_maint_req_p,
# When $scheduled_operation_p ie scheduled, set notifications and
# possibly cs_announcements
#  timing of alert customers according to parameter SchedRemindersList
#



}

ad_proc -private cs_ticket_message_create {
    args
} {
    Create a message for a ticket_id
    <br/>
    args: customer_id ticket_id privacy_level message internal_notes internal_p
    <br/>
    required args: ticket_id (message or internal_notes)
} {
    upvar 1 instance_id instance_id
    set user_id [ad_conn user_id]
    ##code
    # 
}

ad_proc -public cs_announce {
    announcement_text
    ann_type
    {customer_id_list ""}
    {expiration ""}
    {ticket_id ""}
    {allow_html_p "0"}
} {
    Show announcment to customers who visit customer-service package. 
    Expires when ticket_id expires or expiration, and/or manual expiration.
    If allow_html_p is one, allows html to be in announcement_text
    <br/>
    If customer_id_list is not empty, announcement only applies to customers referenced in customer_id_list.
    <br/>
    Expiration can be relative tcl "now + 3 days, now + 3 hours, now + 15 minutes or yyyy-mm-dd hh:mm:ss"

    @return 1 if no errors, otherwise returns 0.
} {
    set success_p 1

    if { [catch {set expires_ts [clock scan $expiration] } result] } {
        ns_log Notice "cs_announce: instance_id '${instance_id}' user_id '${user_id} expiration '${expiration}' Error '${result}'"
        set success_p 0
    } 

    # cs_announce (cs rep to multple customers) 
    # Send announcement / notifiy to subset of customers by customer_ref, ticket_id is the one
    # that is related to announcement. When ticket_id closes, announcement closes.

    ##code
    
    return $success_p
}

ad_proc -public cs_ticket_open {
    args
} {
    Open a customer-service ticket.

    @return ticket_id, or empty string if fails.
} {
    upvar 1 instance_id instance_id
    # Remember that it might have been closed (already exists and re-opened)
    ##code

    return $ticket_id
}


ad_proc -public cs_ticket_close_by_customer {
    args
} {
    Close ticket by customer rep.
} {
    upvar 1 instance_id instance_id
    set success_p 1

    ##code
    return $success_p
}

ad_proc -public cs_ticket_close_by_rep {
    args
} {
    Close ticket by customer support.
} {
    upvar 1 instance_id instance_id
    set success_p 1
    ##code

    return $success_p
}

ad_proc -private cs_ticket_subscribe {
    ticket_id
    user_id_list
} {
    Subscribe user_ids to ticket.
} {
    upvar 1 instance_id instance_id
    # subscribe user to ticket_id
    set success_p 1

    ##code
    return $success_p
}

ad_proc -private cs_ticket_unsubscribe {
    ticket_id
    user_id_list
} {
    Unsubscribe user_ids to ticket.
} {
    upvar 1 instance_id instance_id
    # unsubscribe user to ticket_id
    set success_p 1

    ##code
    return $success_p
}


ad_proc -private cs_ticket_subscriptions_change {
    args
} {
    Change subscriptions for a ticket.
} {
    upvar 1 instance_id instance_id
    # cs_ticket_subscriptions_change
    set success_p 1

    ##code 
    return $success_p
}

ad_proc -private cs_ticket_message_create {
    args
} {
    Post a message to a ticket.
} {
    upvar 1 instance_id instance_id
    # cs_ticket_subscriptions_change
    set success_p 1

    ##code 
    return $success_p
}


ad_proc -private cs_categories {
} {
    Read categories as a list of lists.
} {
    upvar 1 instance_id instance_id
    ##code
    return $categories_lists
}



ad_proc -private cs_notify_customer_reps {
    ticket_id
    {subject ""}
    {message ""}
    {immediate_p "1"}
    {message_id ""}
} {
    Notify customer reps that subscribe to ticket.
} {
    # based on hf_monitor_alert_trigger (code extracted below)
    # sender email is systemowner
    # to get user_id of systemowner:
    # party::get_by_email -email $email
    set sysowner_email [ad_system_owner]
    set sysowner_user_id [party::get_by_email -email $sysowner_email]

    # What users to send alert to?
    set users_list [cs_customer_reps_of_ticket $ticket_id]
    if { [llength $users_list] > 0 } {
        # get TO emails from user_id
        set email_addrs_list [list ]
        foreach uid $users_list {
            lappend email_addrs_list [party::email -party_id $uid]
        }
        
        # What else is needed to send alert message?
        set ticket_ref [cs_t_ref_from_id $ticket_id]
        set subject "#customer-service.ticket# #customer-service.Asset_Monitor# id ${monitor_id} for ${label}: ${alert_title}"
        set body $alert_message
        # post to logged in user pages 
        hf_log_create $asset_id "#customer-service.Asset_Monitor#" "alert" "id ${monitor_id} ${subject} \n Message: ${body}" $user_id $instance_id 

        # send email message
        append body "#customer-service.Alerts_can_be_customized#. #customer-service.See_asset_configuration_for_details#."
        acs_mail_lite::send -send_immediately $immediate_p -to_addr $email_addrs_list -from_addr $sysowner_email -subject $subject -body $body

        # log/update alert status
        if { $immediate_p } {
            # show email has been sent
            
        } else {
            # show email has been scheduled for sending.
            ns_log Notice "cs_notify_customer_reps. ticket_id '${ticket_id}' message_id '${message_id}'"
        }
    }
    return 1
}


ad_proc -private cs_notify_support_reps {
    ticket_id
    {subject ""}
    {message ""}
    {immediate_p "1"}
    {message_id ""}
} {
    Notify support reps that subscribe to ticket.
} {
    # based on hf_monitor_alert_trigger (code extracted below)
    # sender email is systemowner
    # to get user_id of systemowner:
    # party::get_by_email -email $email
    set sysowner_email [ad_system_owner]
    set sysowner_user_id [party::get_by_email -email $sysowner_email]

    # What users to send alert to?
    set users_list [cs_support_reps_of_ticket $ticket_id]
    if { [llength $users_list] > 0 } {
        # get TO emails from user_id
        set email_addrs_list [list ]
        foreach uid $users_list {
            lappend email_addrs_list [party::email -party_id $uid]
        }
        
        # What else is needed to send alert message?
        set ticket_ref [cs_t_ref_from_id $ticket_id]
        set subject "#customer-service.ticket# #customer-service.Asset_Monitor# id ${monitor_id} for ${label}: ${alert_title}"
        set body $alert_message
        # post to logged in user pages 
        hf_log_create $asset_id "#customer-service.Asset_Monitor#" "alert" "id ${monitor_id} ${subject} \n Message: ${body}" $user_id $instance_id 

        # send email message
        append body "#customer-service.Alerts_can_be_customized#. #customer-service.See_asset_configuration_for_details#."
        acs_mail_lite::send -send_immediately $immediate_p -to_addr $email_addrs_list -from_addr $sysowner_email -subject $subject -body $body

        # log/update alert status
        if { $immediate_p } {
            # show email has been sent
            
        } else {
            # show email has been scheduled for sending.
            ns_log Notice "cs_notify_support_reps. ticket_id '${ticket_id}' message_id '${message_id}'"
        }
    }
    return 1
}
