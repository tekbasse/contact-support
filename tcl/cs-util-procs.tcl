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

# cs_cat_role_map_create
# cs_cat_role_map_del

# cs_notify_customer_reps $ticket

# URL to ticket or ticket/message (handled by www/index.vuh)
# cs_ticket_to_url ticket_nbr (message_nbr), if message_nbr supplied, just ref message #
#  if ticket and message# supplied, url should be for whole ticket with #message via ID tag.
# ticket number is unqiue alphanumeric reference to hide system ticket and message number, based on open timestamp.

