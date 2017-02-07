#customer-service/tcl/cs-util-procs.tcl
ad_library {

    misc API for customer-service
    @creation-date 21 Jan 2017
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}

# qc_properties  returns list of properties (defined in accounts-ledger)

ad_proc -private cs_customer_ids_of_user_id { 
    {user_id ""}
} {
    Returns list of customer_id available to user_id in a customer's role position.
} {
    upvar 1 instance_id instance_id
    if { ![info exists instance_id] } {
        # set instance_id package_id
        set instance_id [qc_set_instance_id]
    }
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    set package_id [ad_conn package_id]

    #set cs_type qc_parameter_get $instance_id ""
    set cs_type [parameter::get -parameter customerTypesRef -package_id $package_id]

    # Change this SWITCH to whatever other package reference provides a list of customer_ids for user_id
    # Use accounts-ledger api for default, consider a package parameter for other cases
    # qal_contact_ids_of_usr_id  (this handles for vendors, customers, as well as other cases)
    set customer_id_list [list ]
    switch $cs_type -- {
        1 {
            set customer_id_list [qal_customer_ids_of_user_id $user_id ]
        }
        2 {
            set customer_id_list [qal_vendor_ids_of_user_id $user_id ]
        }
        3 {
            ## maybe combine in another proc to reduce query load?
            set customer_id1_list [qal_customer_ids_of_user_id $user_id ]
            set customer_id2_list [qal_vendor_ids_of_user_id $user_id ]
            set customer_id_list [set_union $customer_id1_list $customer_id2_list]
        }
    }
    return $customer_id_list
}


ad_proc -private cs_id_of_t_ref {
    t_ref
} {
    Returns ticket or message_id from cs_ticket_ref_id_map
} {
    upvar 1 instance_id instance_id
    set id ""
    if { [string length $t_ref ] < 201 } {
        db_0or1row cs_ticket_ref_id_map_r1 {select id from cs_ticket_ref_id_map
            where t_ref=:t_ref and instance_id=:instance_id }
    }
    return $id
}


ad_proc -private cs_t_ref_of_id {
    ticket_id
} {
    Returns t_ref of ticket from ticket_id, or empty string if not found.
} {
    upvar 1 instance_id instance_id
    set t_ref ""
    if { [qf_is_natural_number $ticket_id] } {
        db_0or1row cs_ticket_ref_id_map_r2 {select t_ref from cs_ticket_ref_id_map
            where t_ref=:t_ref and instance_id=:instance_id }
    }
    return $t_ref
}


ad_proc -private cs_id_seq_nextval {
    {t_ref_name ""}
} {
    Returns nextval of cs_id_seq, after generating a cooresponding randomized reference.
    If t_ref_name is provided, value of t_ref is set to variable name passed to t_ref_name.
} {
    upvar 1 instance_id instance_id
    if { $t_ref_name ne "" } {
        if { [hf_are_safe_and_visible_characters_q $t_ref_name] } {
            upvar 1 $t_ref_name t_ref
        }
    }
    set id [db_nextval cs_id_seq]
    #  number of characters as in a uuid = 32
    # number of possibilities per character = 16 (hexadecimal)
    # total permutations = 3.4028236692093846e+38
    
    # ad_generate_random_string returns 
    # 26 + 10 = 36 possibilities per character 
    # If number of characters = 25
    # total permutations = 8.08281277464764e+38

    set exists_p 0
    set count 0
    set t_len 25
    while { $exists_p ne 1 && $count < 100 } {
        incr count
        set t_ref [ad_generate_random_string $t_len]
        set id [cs_id_from_t_ref $t_ref]
        if { $id ne "" } {
            set exists_p 1
            if { $count < 5 } {
                ns_log Notice "cs_id_seq_nextval.79: \
 generated a nonunique ref: '${t_ref}'. This should be rare."
            } elseif { $count < 90 } {
                ns_log Warning "cs_id_seq_nextval.81: \
 is generating too many ref. collisions. Change to another randomization proc."
            } else {
                # This should not happen.
                ns_log Warning "cs_id_seq_nextval.84: \
 Error. This is generating too many ref. collisions. Increasing length."
                incr t_len
            }
        } else {
            set exists_p 0
            db_dml cs_id_seq_nextval_w {
                insert into cs_ticket_ref_id_map 
                (instance_id,id,t_ref) values (:instance_id,:id,:t_ref)
            }
        }
    }
    return $id
}
    


ad_proc -private cs_category_create {
    args
} {
    Create a category entry. args are: parent_id order_value label name active_p cs_property_label cc_property_label description.
    <br/>
    cs_property_label is the property label for customer support reps. default: non_assets
    <br/>
    cc_property_label is the property label for customers. default: non_assets


    @return id if created. Otherwise returns empty string.
} {
    upvar 1 instance_id instance_id
    set id ""
    set parent_id ""
    set order_value "100"
    set label ""
    set name ""
    set active_p 1
    set cs_property_label "non_assets"
    set cc_property_label "non_assets"
    set description ""

    set key_list [list ]
    set val_list [list ]
    foreach {name value} $args {
        lappend key_list $name
        lappend val_list $value
    }

    # validate
    set active_p [qf_is_true $active_p]
    set ov_ok [qf_is_natural_number $order_value]
    set name [qf_abbrev $name 78]
    if { $label eq "" } {
        set label [qf_abbrev $name 38]
        regsub -all -- { } $label {_} label
    } else {
        set label [qf_abbrev $label 38]        
    }
    set pl_list [qc_property_list $instance_id]
    if { $cs_property_label in $pl_list && $cc_property_label in $pl_list } {
        set id [db_nextval cs_id_seq]
        db_dml cs_categories_write { insert into cs_categories 
            (instance_id,id,parent_id,order_value,label,name,active_p,cs_property_label,cc_property_label,description)
            values (:instance_id,:id,:parent_id,:order_value,:label,:name,:active_p,:cs_property_label,:cc_property_label,:description)
        }
    } else {
        ns_log Notice "cs_category_create: failed. \
 instance_id '${instance_id}' label '${label}' cs_property_label '${cs_property_label}' cc_property_label '${cc_property_label}'"
    }
    return $id
}

ad_proc -private cs_category_trash {
    id_list
} {
    Trashes a category entry by setting active_p false.

    @return 1 if trashed. Otherwise returns 0
} {
    upvar 1 instance_id instance_id
    set  id2_list [qf_listify $id_list]
    set success_p 0
    if { [llength $id2_list ] > 0 } {
        set success_p [hf_natural_number_list_validate $id2_list]
        db_dml cs_categories_trash "update cs_categories set active_p='0' where instance_id=:instannce_id and id in ([template::util::tcl_to_sql_list])"
    }
    return $success_p
}

ad_proc -private cs_support_reps_of_ticket { 
    ticket_id
} {
    Returns list of user_ids of customer support reps associated with ticket.
} {
    upvar 1 instance_id instance_id
    set uid_list [db_list cs_support_rep_ticket_map_r_uid {select user_id from cs_support_rep_ticket_map
        where instance_id=:instance_id
        and ticket_id=:ticket_id}]
    return $uid_list
}

ad_proc -private cs_customer_reps_of_ticket {
    ticket_id
} {
    Returns list of user_ids of customer reps associated with ticket.
} {
    upvar 1 instance_id instance_id
    set uid_list [db_list cs_customer_rep_ticket_map_r_uid {select user_id from cs_customer_rep_ticket_map
        where instance_id=:instance_id
        and ticket_id=:ticket_id}]
    return $uid_list
}
    



ad_proc -private cs_ticket_action_log_cr {
    ticket_id
    cs_rep_ids
    customer_user_ids
    op_type
} {
    Logs a ticket action.
} {
    upvar 1 instance_id instance_id
    set success_p 1
    if { [ns_isconnected] } {
        set user_id [ad_conn user_id]
    } else {
        set user_id $instance_id
    }
    if { [qf_is_natural_number $ticket_id] } {
        set cs_rep_ids_list [qf_listify $cs_rep_ids]

        if { [hf_natural_number_list_validate $cs_rep_ids_list] } {
            set cu_ids_list [qf_listify $customer_user_ids] 

            if { [hf_natural_number_list_validate $cu_ids_list ] } {

                if { ![string length $op_type] < 9 } {
                    set success_p 0
                }
            } else {
                set success_p 0
            }
        } else {
            set success_p 0
        }
    } else {
        set success_p 0
    }
    if { $success_p } {
        db_dml cs_ticket_action_log_cr {insert into cs_ticket_action_log
            (ticket_id,instance_id,cs_rep_ids,customer_user_ids,op_type,op_by,op_time)
            values (:ticket_id,:instance_id,:cs_rep_ids,:customer_user_ids,:op_type,:user_id,now()) }
    } else {
        ns_log Warning "cs_ticket_action_log_cr. Could not write action. \
    ticket_id '${ticket_id}' user_id '${user_id}' instance_id '${instance_id}' \
    cs_rep_ids '${cs_rep_ids}' customer_user_ids '${customer_usr_ids}' op_type '${op_type}'"
    }
    return $success_p
}

ad_proc -private cs_median_human_time {
    seconds_list
} {
    Converts a list of integer seconds into a median value in common time units of days, hours, minutes.
    Only the most significant two units are returned.
    A minimum of three values required, otherwise empty string is returned.
} {
    set seconds_count [llength $seconds_list]
    if { $seconds_count > 3 } {
        set seconds_sorted_list [lsort -integer $seconds_list]
        set median_idx [expr { $seconds_count / 2} ]
        set median [lindex $seconds_sorted_list $median_idx]
        set day_s 86400
        set hour_s 3600
        set minute_s 60
        if { $median > $day_s } {
            set days [expr { $median / $day_s } ]
            set median [expr { $median - ( $days * $day_s ) } ]
            if { $days > 1 } {
                append etr_time " ${days} #customer-service.days#"
            } else {
                append etr_time " ${days} #customer-service.day#"
            }
        } else {
            set days 0
        }
        if { $median > $hour_s } {
            set hours [expr { $median / $hour_s } ]
            set median [expr { $median - ( $hours * $hour_s ) } ]
            if { $hours > 1 } {
                append etr_time " ${hours} #customer-service.hours#"
            } else {
                append etr_time " ${hours} #customer-service.hour#"
            }
        } else {
            set hours 0
        }
        if { $median > $minute_s } {
            set minutes [expr { $median / $minute_s } ]
            set median [expr { $median - ( $minutes * $minute_s ) } ]
        } else {
            set minutes 0
        }
        incr minutes 1
        if { $minutes > 0 && $days == 0 } {
            if { $minutes < 2 } {
                append etr_time " ${minutes} #customer-service.minute#"
            } else {
                append etr_time " ${minutes} #customer-service.minutes#"
            }
        }
    }
    return $etr_time
}