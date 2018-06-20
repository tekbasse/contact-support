set title "Announcements"
set context [list [list index "Documentation"] $title]

# Announcements mainly refers to 
# service announcements that support reps may use
# to reach users that visit the contact-support package.

# The purpose is to minimize the burden of duplicate tickets 
# associated with an issue that extends to more than one contact.
# Or to post a notice to users visiting contact-support 
# within a limited period without sending messages external to the system.

set instance_id [ad_conn package_id ]

set id_list [cs_announcement_ids ]

set headings_list [ \
                        "#contact-support.ID" \
                        "#acs-kernel.common_Type#" \
                        "#acs-datetime.Start#" \
                        "#acs-datetime.End#" \
                        "#contact-support.Expired_#" \
                        "#contact-support.Allow_HTML_#" \
                        "#contact-support.Announcement#" ]

set announcements_lists [cs_announcements $id_list]
# id ann_type ticket_id start_timestamp expire_timestamp expired_p allow_html_p announcement

# agenda_lists:
# id, ann_type, ticket_id, start_timestamp, expire_timestamp, expired_p,allow_html_p,announcement
# where expired != 1
set non_assets_agenda_lists [cs_announcements_agenda "non_assets" ]
set assets_agenda_lists [cs_announcements "assets" ]

