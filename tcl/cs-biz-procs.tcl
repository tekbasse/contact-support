#contact-support/tcl/cs-biz-procs.tcl
ad_library {

    business procs for contact-support
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/contact-support
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}

# contact-support.contact_id references refer to accounts-ledeger.contact_id
# so that package can be used  with contacts, customers, or vendors.

ad_proc -public cs_ticket_create {
    args
} {
    Create a ticket. Returns ticket_id. 
    If ticket_ref_name is defined, assigns the variable name of ticket_ref_name to the ticket's external reference.
    <br/>
    args: 
    contact_id authenticated_by ticket_category_id current_tier_level subject message internal_notes ignore_reopen_p unscheduled_service_req_p scheduled_operation_p scheduled_maint_req_p priority ann_type ann_message ann_message_type
    <br/>
    See c_tickets table definition for usage. ann_type, ann_message, and ann_message_type is from cs_announcements table: ann_type, message, message_type 
    <br/>
    To open a ticket with an announcement about a scheduled event, set ann_type to "MEMO"
    
} {
    upvar 1 instance_id instance_id

    set p [list \
               ticket_id \
               ticket_ref_name \
               contact_id \
               authenticated_by \
               ticket_category_id \
               current_tier_level \
               subject \
               message \
               internal_notes \
               cs_open_p \
               privacy_level \
               ignore_reopen_p \
               unsecheduled_service_req_p \
               scheduled_operation_p \
               scheduled_maint_req_p \
               priority \
               ticket_ref_name \
               ann_type \
               ann_message \
               ann_message_type \
              ]

    qf_nv_list_to_vars $args $p

    if { $ticket_ref_name ne "" && [hf_list_filter_by_alphanum [list $ticket_ref_name]] } {
        upvar 1 $ticket_ref_name ticket_ref
    }
    set success_p 1
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
    ns_log Notice "cs_ticket_create ticket_id '${ticket_id}' by user_id '${user_id}'"

    if { $ann_type ne "" && [hf_list_filter_by_alphanum [list $ann_type]] } {
        set ann_type [string range $ann_type 0 7]
    } else {
        set ann_type ""
        ns_log Notice "cs_ticket_create: ann_type '${ann_type}' not valid. ignoring."
    }

    db_dml cs_tickets_cr {insert into cs_tickets
        (ticket_id,instance_id,contact_id,authenticated_by,ticket_category_id,
         current_tier_level,subject,cs_open_p,opened_by,cs_time_opened,
         user_open_p,user_time_opened,privacy_level,trashed_p,
         ignore_reopen_p,unscheduled_service_req_p,scheduled_operation_p,
         scheduled_maint_req_p,priority)
        values (:ticket_id,:instance_id,:contact_id,:authenticated_by,:ticket_category_id,
                :current_tier_level,:subject,:cs_open_p,:opened_by,:cs_time_opened,
                :user_open_p,:user_time_opened,:privacy_level,:trashed_p,
                :ignore_reopen_p,:unscheduled_service_req_p,:scheduled_operation_p,
                :scheduled_maint_req_p,:priority)
    }

    cs_ticket_message_create ticket_id $ticket_id contact_id $contact_id privacy_level $privacy_level subject $subject message $message internal_notes $internal_notes internal_p $internal_p

    if { $scheduled_maint_req_p && $scheduled_operations_p && $ann_type ne "" } {

        # Operation has been scheduled with ticket creation.
        # set any annoucements (and advanced notices ie scheduled messages) associated with scheduled event
        if { $ann_message eq "" } {
            set ann_message $message
        }
        cs_announcement_create
        ##code        

    }
    return $success_p
}

ad_proc -private cs_ticket_message_create {
    args
} {
    Create a message for a ticket_id
    <br/>
    args: contact_id ticket_id ticket_ref privacy_level message internal_notes internal_p user_id
    <br/>
    required args: (ticket_id or ticket_ref ) (message or internal_notes)
    <br/>
    user_id is used only when posting from a scheduled proc.
    <br/>
    Returns message_ref or empty string if input doesn't validate.
} {
    upvar 1 instance_id instance_id
    set success_p 1
    set message_ref ""
    set p [list ticket_id ticket_ref privacy_level message internal_notes internal_p user_id]
    qf_nv_list_to_vars $args $p
    if { [ns_conn isconnected] } {
        set posted_by [ad_conn user_id]
    } else {
        set posted_by $user_id
    }
    set message
    if { $message eq "" && $internal_notes eq "" } {
        set success_p 0
        ns_log Notice "cs_ticket_message_create.146: input error. message '' internal_notes '' instance_id '${instance_id}' "
    }
    if { $ticket_id eq "" && $success_p } { 
        set ticket_or_message_id [cs_id_of_t_ref $ticket_ref]
        # cross-ref to ticket_id

        if { $ticket_id eq "" } {
            ns_log Warning "cs_ticket_message_create.153: instance_id '${instance_id}' ticket_ref '${ticket_ref}' ticket_id ''"
            set success_p 0
        }
    }
    if { $success_p } {
        set message_id [cs_id_seq_nextval message_ref]
        # set message_ref  --external reference of message_id (returned by cs_id_seq_nextval)
        db_dml 
    ##code
    }
    return $message_ref
}


ad_proc -private cs_new_event_announce {
    args
} {
    Set annoucements in contact-support for newly scheduled event
} {
    if { $scheduled_maint_req_p && $scheduled_operations_p && !$prior_sched_op_p } {

    if { $begins eq "" } {
        set begins "now"
    }
    if { [catch {set begins_ts [clock scan $begins] } result] } {
        ns_log Notice "cs_announcement: instance_id '${instance_id}' user_id '${user_id} begins '${begins}' Error '${result}'"
        if { [ns_conn isconnected] } {
            set err_message $begins 
            append err_message " " $result
            util_user_message -message $err_message
            set allow_html_p 0
        }
        set success_p 0
    } else {
        set begins_timestamp_utc [clock format $begins_ts -gmt true]

    }

    if { $expiration eq "" && $success_p } {
        # set default expiration 
        set expiration_dur [cs_stats_ticket_close 0]
        set expiration $begins
        set package_id [ad_conn package_id]
        if { $expiration_dur eq "" } {
            append expiration " + " [parameter::get -parameter schedEventDurationSuperDefault -package_id $package_id]
        } else {
            set expiration_dur_s [parameter::get -parameter schedEventDurationDefault -package_id $package_id]
            append expiration " + " "${expiration_dur_s} seconds"
        }
    }
    if { [catch {set expires_ts [clock scan $expiration] } result] } {
        ns_log Notice "cs_announcement: instance_id '${instance_id}' user_id '${user_id} expiration '${expiration}' Error '${result}'"
        if { [ns_conn isconnected] } {
            set err_message $expiration 
            append err_message " " $result
            util_user_message -message $err_message
            set allow_html_p 0
        }
        set success_p 0
    } else {
        set expires_timestamp_utc [clock format $expires_ts -gmt true]
    }


        set tz [qal_contact_tz $contact_id]
        set begins_ltz [lc_time_utc_to_local $begins_timestamp_utc $tz]    
        set expires_ltz [lc_time_utc_to_local $expires_timestamp_utc $tz]
    if { [qf_is_natural_number $ticket_id ] } {
        if { $contact_id_list_len == 1  } {
            # automatically convert any "ticket_ref" in announcement into a (linked) reference 
            set ticket_ref [cs_t_ref_of_id $ticket_id]
            if { $ticket_ref ne "" } {
                if { $allow_html_p } {
                    set ticket_ref [cs_ticket_url_of_t_ref $ticket_ref link]
                }
                regsub -all -- {ticket_ref} $announcement_text $ticket_ref announcement_text
                set op_done_p 0
                # record in cs_ticket_op_periods
                db_dml cs_ticket_op_periods_cr {
                    insert into cs_ticket_op_periods 
                    (instance_id,ticket_id,start_ts,end_ts,op_done_p)
                    values (:instance_id,:ticket_id,:begins_timestamp_utc,:expires_timestamp_utc)
                }
                set ticket_list [cs_ticket_read $ticket_id]
                qf_nv_list_to_vars $ticket_list contact_id
                set ticket_contact_id $contact_id
            }
        } else {
            # don't share a ticket_ref with other contacts_ids
            ns_log Notice "cs_announcement: instance_id '${instance_id}' user_id '${user_id} ticket_id '${ticket_id}' ticket_ref withheld. Should not be shared with external contact_id(s)."
            regsub -all -- {ticket_ref} $announcement_text "#contact-support.ticket_ref_confidential#" announcement_text
            
        }
    } elseif { $ticket_id ne "" } {
        ns_log Warning "cs_announcement: instance_id '${instance_id}' user_id '${user_id} ticket_id '${ticket_id}' not valid"
    }
        
        # Operation is just now scheduled. Trigger:
        #  set notifications 
        cs_sched_messages_create message_type $message_type begins $begins ticket_id $ticket_id message $message privacy_level $privacy_level
        #  and cs_announcement_create
        cs_announcement_create 

    }
}

ad_proc -private cs_announcement_create {
    announcement_text
    ann_type
    {contact_id_list ""}
    {user_id_list ""}
    {begins "now"}
    {expiration ""}
    {ticket_id ""}
    {allow_html_p "0"}
} {
    Create an announcment for relevant contacts who visit contact-support package. 
    Event begins at "begins" time stamp. If empty, defaults to "now".
    Event expires when ticket_id expires or expiration, and/or manual expiration.
    If allow_html_p is one, allows html to be in announcement_text
    <br/>
    If contact_id_list or user_id_list is not empty, announcement only applies to referenced in contact_id_list and/or user_id_list.
    <br/>
    If ticket_id exists, announcement ends when ticket_id closes.
    <br/>
    Values of <code>begins</code> and <code>expiration</code> can be relative tcl "now + 3 days, now + 3 hours, now + 15 minutes or yyyy-mm-dd hh:mm:ss"

    @return 1 if no errors, otherwise returns 0.
} {
    upvar 1 instance_id instance_id
    set success_p 1
    if { $contact_id_list ne "" } {
        set success_p [hf_list_filter_by_natural_number $contact_id_list]
    }
    if { $success_p && $user_id_list ne "" } {
        set success_p [hf_list_filter_by_natural_number $user_id_list]
    }

    if { $success_p } {
        set id [db_nextval cs_id_seq]
        # relatives okay with: clock format \[clock scan "now + 3 days"\]
        # relative vocabulary includes year, month, week, day, hours, today, now 
        db_dml cs_announcements_cr {insert into cs_announcements
            (instance_id,id,ann_type,ticket_id,expire_timestamp,expired_p,announcement)
            values (:instance_id,:id,:ann_type,:ticket_id,:expire_timestamp,:expired_p,:announcement)
        }
        set user_id ""
        set notify_p 0
        foreach contact_id $contact_id_list {
            db_dml cs_ann_user_contact_map_cr { insert into cs_ann_user_contact_map 
                (instance_id,ann_id,user_id,contact_id,notify_p)
                values (:instance_id,:ann_id,:user_id,:contact_id,:notify_p)
            }
        }
        set contact_id ""
        foreach user_id $user_id_list {
            db_dml cs_ann_user_contact_map_cr { insert into cs_ann_user_contact_map 
                (instance_id,ann_id,user_id,contact_id,notify_p)
                values (:instance_id,:ann_id,:user_id,:contact_id,:notify_p)
            }
        }


    }
    return $success_p
}

ad_proc -private cs_sched_messages_create {
    args
} {
    Create alerts for a ticket_id
    required args: begins message privacy_level ticket_id
    <br/>
    defaults: message_type ('text' or 'html')
    <br/>
    For privacy_level meaning, see table comments for cs_tickets.privacy_label
    <br/>
    Returns 1 if successful, otherwise returns 0.
    
} {
    upvar 1 instance_id instance_id
    set triggered_p 0
    set message_type "text"    
    set names_list [list message_type begins ticket_id message privacy_level]

    set ignored_list [qf_nv_list_to_vars $args $names_list]
    if { [llength $ignored_list ] > 0 } {
        ns_log Notice "cs_announcement.296: ignored: '${ignored_list}'"
    }
    #  timing of alert contacts according to parameter schedRemindersList
    set package_id [ad_conn package_id]
    set sched_reminder [parameter::get -parameter schedRemindersList -package_id $package_id]
    set sched_reminder_list [split $sched_reminder ","]
    set now_ts [clock seconds]
    foreach sr_ts $sched_reminder_list {
        set trigger $begins
        append trigger " - " $sr_ts
        if { [catch {set trigger_ts [clock scan $trigger] } result] } {
            if { [ns_conn isconnected] } {
                set user_id [ad_conn user_id]
                ns_log Notice "cs_announcement.309: instance_id '${instance_id}' user_id '${user_id} trigger '${trigger}' Error '${result}'"
                set err_message $trigger
                append err_message " " $result
                util_user_message -message $err_message
            } else {
                ns_log Notice "cs_announcement.314: instance_id '${instance_id}' trigger '${trigger}' Error '${result}'"
            }
            set success_p 0
        } else {
            set trigger_timestamp_utc [clock format $trigger_ts -gmt true]
        }
        if { $success_p && $trigger_ts > $now_ts } {
            db_dml { insert into cs_sched_messages
                (instance_id,ticket_id,trigger_ts,triggered_p,message,privacy_level,message_type)
                values (:instance_id,:ticket_id,:trigger_ts,:triggered_p,:message,:privacy_level,:message_type)
            }
        }
    }
    return $success_p
}

ad_proc -public cs_ticket_open {
    args
} {
    Open a contact-support ticket.

    @return ticket_id, or empty string if fails.
} {
    upvar 1 instance_id instance_id
    # Remember that it might have been closed (already exists and re-opened)
    ##code

    return $ticket_id
}


ad_proc -public cs_ticket_close_by_contact {
    args
} {
    Close ticket by contact rep.
} {
    upvar 1 instance_id instance_id
    set success_p 1

    ##code
    return $success_p
}

ad_proc -public cs_ticket_close_by_rep {
    args
} {
    Close ticket by support rep.
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


ad_proc -private cs_category_subscriptions {
    args
} {
    Changes subscriptions for a ticket category.
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



ad_proc -private cs_notify_contact_reps {
    ticket_id
    {subject ""}
    {message ""}
    {immediate_p "1"}
    {message_id ""}
} {
    Notify contact reps that subscribe to ticket.
} {
    upvar 1 instance_id instance_id
    # based on hf_monitor_alert_trigger (code extracted below)
    # sender email is systemowner
    # to get user_id of systemowner:
    # party::get_by_email -email $email
    set sysowner_email [ad_system_owner]
    set sysowner_user_id [party::get_by_email -email $sysowner_email]

    # What users to send alert to?
    set users_list [cs_contact_reps_of_ticket $ticket_id]
    if { [llength $users_list] > 0 } {
        # get TO emails from user_id
        set email_addrs_list [list ]
        foreach uid $users_list {
            lappend email_addrs_list [party::email -party_id $uid]
        }
        
        # What else is needed to send alert message?
        set ticket_ref [cs_t_ref_from_id $ticket_id]
        set subject "#contact-support.ticket# #contact-support.Asset_Monitor# id ${monitor_id} for ${label}: ${alert_title}"
        set body $alert_message
        # post to logged in user pages 
        hf_log_create $asset_id "#contact-support.Asset_Monitor#" "alert" "id ${monitor_id} ${subject} \n Message: ${body}" $user_id $instance_id 

        # send email message
        append body "#contact-support.Alerts_can_be_customized#. #contact-support.See_asset_configuration_for_details#."
        acs_mail_lite::send -send_immediately $immediate_p -to_addr $email_addrs_list -from_addr $sysowner_email -subject $subject -body $body

        # log/update alert status
        if { $immediate_p } {
            # show email has been sent
            
        } else {
            # show email has been scheduled for sending.
            ns_log Notice "cs_notify_contact_reps. ticket_id '${ticket_id}' message_id '${message_id}'"
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
    upvar 1 instance_id instance_id
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
        set subject "#contact-support.ticket# #contact-support.Asset_Monitor# id ${monitor_id} for ${label}: ${alert_title}"
        set body $alert_message
        # post to logged in user pages 
        hf_log_create $asset_id "#contact-support.Asset_Monitor#" "alert" "id ${monitor_id} ${subject} \n Message: ${body}" $user_id $instance_id 

        # send email message
        append body "#contact-support.Alerts_can_be_customized#. #contact-support.See_asset_configuration_for_details#."
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

ad_proc -private cs_announcement_close {
    ann_id
    status "#contact-support.resolved#"
} {
    Close announcement_id and notify users that event has ended with status.
} {
    set exists_p [db_0or1row cs_announcement_r1 {select id,ann_type,ticket_id,start_timestamp,expire_timestamp,expired_p,announcement
        from cs_announcements 
        where instance_id=:instance_id
        and id=:ann_id}]
    if { $exists_p } {
        set user_id_list [db_list cs_ann_user_contact_map_user_list {select user_id from
            cs_ann_user_contact_map
            where ann_id=:ann_id
            and instance_id=:instance_id
            and notify_p=!'0'}]
        foreach user_id $user_id_list {

            ##code
            #send a message to these users (no cc...)
        }
        db_dml {update cs_announcements set expired_p='1' where id=:ann_id and instance_id=:instance_id}
        db_dml {update cs_ann_user_contact_map_tr set trashed_p='1' where ann_id=:ann_id and instance_id=:instance_id}
    } else {
        ns_log Warning "cs_annoucement_close: instance_id ${instance_id} ann_id '${ann_id}' does not exist."
    }
    return $exists_p
}

