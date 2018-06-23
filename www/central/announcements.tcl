set title "#contact-support.Announcements#"
set context [list [list index "#contact-support.Support#"] $title]

# show list of active annoucements, 
# an expire button for each, 
# and link for each to the associated ticket itself



# Announcements mainly refers to 
# service announcements that support reps may use
# to reach users that visit the contact-support package.

# The purpose is to minimize the burden of duplicate tickets 
# associated with an issue that extends to more than one contact.
# Or to post a notice to users visiting contact-support 
# within a limited period without sending messages external to the system.

set instance_id [ad_conn package_id ]

set input_array(s) "2"
set input_array(p) ""
set input_array(this_start_row) ""
set form_posted_p [qf_get_inputs_as_array input_array]


set headings_list [list \
                        "#contact-support.ID" \
                        "#acs-kernel.common_Type#" \
                        "#acs-datetime.Start#" \
                        "#acs-datetime.End#" \
                        "#contact-support.Expired_#" \
                        "#contact-support.Allow_HTML_#" \
                        "#contact-support.Announcement#" ]

set id_list [cs_announcement_ids ]

set a_lists [cs_announcements $id_list]
# id ann_type ticket_id start_timestamp expire_timestamp expired_p allow_html_p announcement

# agenda_lists:
# id, ann_type, ticket_id, start_timestamp, expire_timestamp, expired_p,allow_html_p,announcement
# where expired != 1
set a_non_assets_lists [cs_announcements_agenda "non_assets" ]
set a_assets_lists [cs_announcements_agenda "assets" ]
set announcements_lists [concat $a_lists $a_non_assets_lists $a_assets_lists ]

set sort_type_list [list \
                        "-integer" \
                        "-ascii" \
                        "-dictionary" \
                        "-dictionary" \
                        "-integer" \
                        "-integer" \
                        "-ignore" ]

qfo_sp_table_g2 \
    -table_lists_varname announcements_lists \
    -table_html_varname announcements_html \
    -p_varname input_array(p) \
    -s_varname input_array(s) \
    -titles_list_varname headings_list \
    -titles_html_list_varname headings_html \
    -sort_type_list $sort_type_list \
    -this_start_row $input_array(this_start_row)
