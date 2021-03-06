-- contact-support-create.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 2

 -- instead of support_request.sequence_value which tracks sequential number
 -- of tickets opened per day,
 -- List number of tickets opened within a period TBD by parameter
 -- or by number of open tickets ahead (by parameter)
 -- or by average response time to opened tickets within (parameter period) and
 --business hours (parameter). 
CREATE SEQUENCE cs_id_seq start 10000;
SELECT nextval ('cs_id_seq');

CREATE TABLE cs_ticket_ref_id_map (
    instance_id         integer,
    id  integer unique not null,
    t_ref varchar(200) unique not null
); 

create index cs_ticket_ref_id_map_ref_idx on cs_ticket_ref_id_map (t_ref);
create index cs_ticket_ref_id_map_id_idx on cs_ticket_ref_id_map (id);
create index cs_ticket_ref_id_map_instance_idx on cs_ticket_ref_id_map (instance_id);

-- For announcements related to scheduled events associated with a ticket_id, see:
--  cs_sched_messages (trigger_ts, message, privacy_level, message_type)
--  cs_ticket_op_periods (start_ts, end_ts)
CREATE TABLE cs_announcements (
    instance_id           integer,
    id                    integer,
    -- Currently three types: 
    -- 1. BOLO (be on lookout for..)
    --         Only associated with set of contact_id / cs_user_map
    --         Not added to any ticket history.
    --         Shown in contact-support user pages until expired or manually expired.
    -- 2. MEMO 
    --         Added to ticket history for each contact_ref, and notifications sent.
    -- 3. LOG 
    --         Added to internal ticket history for each contact_ref. 
    --         Contacts not notified or shown.
    ann_type              varchar(8),
    -- If associated with a ticket id
    ticket_id             integer,
    -- If starts at some time in the future
    start_timestamp       timestamptz,
    -- If expires
    expire_timestamp      timestamptz,
    -- Users can ask to be notified when this announcement / system wide issue is resolved.
    -- see table cs_ann_user_contact_map 
    -- on_expire_notify_uids text,
    -- state of announcement
    expired_p             varchar(1),
    -- Answers question: support html in announcement? ie @noquote in template?
    allow_html_p          varchar(1),
    -- first line of announcement is subject/title delimited by /n
    -- ie tcl newline indicator
    announcement          text
);

create index cs_announcements_id_idx on cs_announcements (id);
create index cs_announcements_ticket_id_idx on cs_announcements (ticket_id);
create index cs_announcements_expire_ts_idx on cs_announcements (expire_timestamp);
create index cs_announcements_start_ts_idx on cs_announcements (start_timestamp);
create index cs_announcements_expired_p_idx on cs_announcements (expired_p);
create index cs_announcements_instance_id_idx on cs_announcements (instance_id);

CREATE TABLE cs_ann_user_contact_map (
       --maps can be between announcement_id and either user_ids or contact_ids
       instance_id        integer,
       -- announcement_id
       ann_id             integer,
       user_id            integer,
       contact_id         integer,
       trashed_p          varchar(1) default '0',
       -- on expire, notify user_id that event is over.
       notify_p           varchar(1) default '0'
);
create index cs_ann_user_contact_map_instance_id_idx on cs_ann_user_contact_map (instance_id);
create index cs_ann_user_contact_map_user_id_idx on cs_ann_user_contact_map (user_id);
create index cs_ann_user_contact_map_notify_p_idx on cs_ann_user_contact_map (notify_p);
create index cs_ann_user_contact_map_trashed_p_idx on cs_ann_user_contact_map (trashed_p);

 -- terminology:   SST = support ticket state (open/closed)
 --                CST = contact ticket state (open/closed)
 -- When contact opens ticket, both CST and SST are opened for triage.
 -- When contact closes ticket, both CST and SST are closed.
 -- When support closes ticket, both CST and SST are closed
 -- When contact re-opens ticket or replies to ticket, ticket is triaged again by first tier.
 -- When support triages ticket, and more info needed by contact,
 --      ticket is SST is closed, CST remains open.
 -- When support triages new ticket, 
 --      qualified ticket remains open for both CST & SST.
 --      support categories and assigns ticket to a tier level and priority if different than default.
 -- When support triages a previously closed ticket,
 --      qualified ticket remains open for both CST & SST, and notifications sent to previously assigned reps.
 --      otherwise SST is closed (with message sent to contact stating no support response needed).
 --      Contact asked to close CST ticket when they are finished with the topic internally.
 CREATE TABLE cs_tickets (
    ticket_id           integer not null,
    instance_id         integer,
    contact_id          integer not null,
 -- authenticated_by is handy for indirect posts (such as via call center operator)
    authenticated_by    varchar(40),
    -- current category_id
    ticket_category_id  integer,
    current_tier_level  integer,
    subject             varchar(100),
    -- ticket state for support.
    -- Cannot rely on date, because cs_time_closed may exist from prior closing of ticket
    -- if for example cs_time_opened is after cs_time_closed
    cs_open_p           varchar(1),
    -- for history of opened_by, see cs_ticket_action_log.
    --first opened_by:
    opened_by           integer not null,
    --first cs open or response time
    cs_time_opened      timestamptz,
    cs_time_closed      timestamptz,
    cs_closed_by        integer,
    -- ticket state for contacts.
    -- Cannot rely on date, because user_time_closed may exist from prior closing of ticket
    -- if for example user_time_opened is after user_time_closed
    user_open_p         varchar(1),
    --first user open or response time
    user_time_opened    timestamptz,
    user_time_closed    timestamptz,
    user_closed_by      integer,
    -- a number, 0 Minimal privacy requirements
    --           5 Requires ssl to see, no content via notifications.
    --           9 Don't show to any contact rep but submitter via ssl.
    -- default provided by package parameter.
    privacy_level       varchar(1),
    -- Is this ticket trashed?
    trashed_p           varchar(1),
    -- Some ticket trackers lock a ticket to prevent reopening.
    -- Contacts should be allowed to post more info for their own contextual notes.
    -- Answers question: Allow a contact to keep a ticket open
    -- or reopen it for their use without reopening ticket from a support perspective?
    ignore_reopen_p     varchar(1),
    -- Does this ticket represent a service outage or other situation
    -- needing immiediate ie unscheduled intervention?
    -- service_outage_p    varchar(1),
    unscheduled_service_req_p varchar(1), 
    -- scheduled operation
    -- Does this ticket have an operation scheduled?
    scheduled_operation_p varchar(1),
    -- Is this operation part of required maintenance?
    -- If so, and scheduled_operation_p is false, ask to schedule..
    scheduled_maint_req_p varchar(1),
    --             Useful in matters of triage, such as rejecting a ticket.
    priority            integer
);

create index cs_tickets_ticket_id_idx on cs_tickets (ticket_id);
create index cs_tickets_contact_id_idx on cs_tickets (contact_id);
create index cs_tickets_instance_id_idx on cs_tickets (instance_id);
create index cs_tickets_cs_open_p_idx on cs_tickets (cs_open_p);
create index cs_tickets_user_open_p_idx on cs_tickets (user_open_p);
create index cs_tickets_trashed_p_idx on cs_tickets (trashed_p);


CREATE TABLE cs_ticket_stats (
    instance_id         integer,
    -- There can be more than one stat per ticket, because
    -- stats are kept for each tier level
    ticket_id           integer not null,
    -- useful to help segment response depending on triaged/assigned tier_level
    -- tier_level might be automatically initally triaged based on ticket_category_id
    cs_final_tier_level integer,
    cs_first_response_s integer,
    -- This is time to final ticket closing to help anticipate recovery time
    cs_final_response_s integer
);
 -- need an index on ticket_id so value can be updated as ticket evolves.
create index cs_ticket_stats_ticket_id_idx on cs_ticket_stats (ticket_id);
create index cs_ticket_stats_instance_id_idx on cs_ticket_stats (instance_id);


CREATE TABLE cs_ticket_action_log (
    ticket_id          integer not null,
    instance_id        integer,
    -- main log message.
    -- for delegating/screening/escalating
    -- ie any ticket related action, log here and 
    -- cs_ticket_messages.internal_notes

    log_message        text,
    -- cs_rep_ids and contact_user_ids should 
    -- note actual subscriptions, not the changed ones.
    cs_rep_ids         text,
    contact_user_ids  text,
    -- These could change:
    -- a = assigned
    -- d = dropped
    -- c = re/closed
    -- o = re/opened
    -- 
    -- position 0 = cs_reps side
    -- position 1 = contact side
    op_type            varchar(8),
    -- operation initiated by (user_id of rep), or
    -- instance_id = assigned by software (package_id ie object_id)
    op_by              integer,
    op_time            timestamptz default now()
);

create index cs_ticket_action_log_ticket_id_idx on cs_ticket_action_log (ticket_id);
create index cs_ticket_action_log_instance_id_idx on cs_ticket_action_log (instance_id);


CREATE TABLE cs_ticket_messages (
    instance_id      integer,
  -- aka support_content.id
    post_id          integer not null,
  -- aka support_content.support_request_id
    ticket_id        integer not null,
    posted_by        integer not null,
    post_time        timestamptz not null,
  -- aka support_content.details
    message          text,
    --             See cs_tickets for more details.
    privacy_level    varchar(1),
    -- internal notes includes the values of variable_names_avail, if any;
    -- and actions, such as ticket status changes, cgi vars passed in a form, as well
    -- as internal notes for ticket solvers etc.
    internal_notes   text,
    -- A space delimited list of initial cs representative user_ids.
    -- Unsubscribing adds a message to that effect.
    -- Use cs_ticket_rep_map for current ones.
    -- This has been moved to cs_ticket_action_log
    -- assigned_to      text,

    -- A space delimited list of initial contact user_ids. 
    -- Unsubscribing adds a message to that effect.
    -- Use cs_ticket_users_map for current ones.
    -- This has been moved to cs_ticket_action_log
    -- subscribed       text,

    -- Is this a log / note for internal view/use only?
    internal_p       varchar(1),
    trashed_p        varchar(1)
);

create index cs_ticket_messages_ticket_id_idx on cs_ticket_messages (ticket_id);
create index cs_ticket_messages_instance_id_idx on  cs_ticket_messages (instance_id);
create index cs_ticket_messages_trashed_p_idx on cs_ticket_messages (trashed_p);
create index cs_ticket_messages_post_id_idx on cs_ticket_messages (post_id);

CREATE TABLE cs_contact_stats (
    instance_id      integer,
    contact_id      integer,
    ticket_id        integer,
    -- The cs message_id might not be the prior id in a sequence.
    -- Contact might post multiple messages between responses
    -- from cs.
    -- cs_message_id and message_id are the reference points
    -- for calculating duration_to_reply_s
    cs_message_id       integer,
    message_id          integer,
    duration_to_reply_s integer,
    -- Day of week of contact reply. Hint:
    -- clock format \clock seconds\ -format %w (or %u)
    -- 0 = Sunday, 1 = monday, 6 = saturday, 7 = sunday
    -- use int(fmod(%w or %u, 7)) to standardize Sundays to 0.
    weekday_n           integer,
    -- time of day in divided into 144 ten minute segments.
    -- That is %H hour time * 6 + %M minutes after hour / 10

    -- Hint:
    -- set hm_list \clock format \clock seconds\ -format "%H %M"\ 
    -- set time_m \expr \lindex hm 0\ * 6 + \lindex hm 1\ / 10 \
    time_m              integer
);

create index cs_contact_stats_ticket_id_idx on cs_contact_stats(ticket_id);
create index cs_contact_stats_instance_id_idx on  cs_contact_stats(instance_id);
create index cs_contact_stats_contact_id_idx on cs_contact_stats(contact_id);

 --aka canned_response table
CREATE TABLE cs_message_templates (
    template_id      integer not null primary key,
    instance_id      integer,
    -- automatically inactivate old, and issue new tempalate_id
    active_p         varchar(1),
    label            varchar(30),
    title            varchar(100),
    subject          varchar(200),
    -- this lists the variable names that contact support can
    -- use in this particular email -- for info only
    variables        text,
    message_content  text,
    created          timestamptz not null,
    created_by       integer
);

create index cs_message_templates_template_id_idx on cs_message_templates(template_id);
create index cs_message_templates_instance_id_idx on cs_message_templates(instance_id);
create index cs_message_templates_label_idx on cs_message_templates(label);

CREATE TABLE cs_categories (
    instance_id      integer,
    id               integer not null,
    -- if this a sub category of another category, parent category_id
    parent_id        integer,
    -- to sort categories
    order_value      integer,
    label            varchar(40),
    name             varchar(80),
    active_p         varchar(1) default '1',
    trashed_p        varchar(1) default '0',
    -- qc_permission_p qc_property.property_label 
    -- Assume property_label is 'non_asset' unless specified.
    -- This way, categories for contact can be filtered to just those with related role permission
    -- Automatic contact subscriptions are based on those who have write/admin permission for property_label
    -- And cs_reps might be initially assigned based on role permission? No
    -- cs_reps assigned based on category and their concact_id's property label. 
    cs_property_label   varchar(24) default 'non_assets',
    -- and
    -- contact reps based on contact_id property_label
    cc_property_label   varchar(24) default 'non_assets',
    description      text
);

create index cs_categories_instance_id_idx on cs_categories(instance_id);
create index cs_categories_id_idx on cs_categories(id);
create index cs_categories_trashed_p_idx on cs_categories(trashed_p);
create index cs_categories_label_idx on cs_categories(label);
create index cs_categories_parent_id_idx on cs_categories(parent_id);

-- ticket_id subscribers (users) map
CREATE TABLE cs_contact_rep_ticket_map (
       instance_id   integer,
       ticket_id     integer,
       -- one record for each contact / user_id that currently subscribes to ticket
       user_id       integer
);

create index cs_contact_rep_ticket_map_instance_id_idx on cs_contact_rep_ticket_map(instance_id);
create index cs_contact_rep_ticket_map_ticket_id_idx on cs_contact_rep_ticket_map(ticket_id);
create index cs_contact_rep_ticket_map_user_id_idx on cs_contact_rep_ticket_map(user_id);


-- ticket_id cs_rep (admins) map
CREATE TABLE cs_support_rep_ticket_map (
       instance_id   integer,
       ticket_id     integer,
       -- one record for each cs rep / admin user_id that is currently assigned to ticket
       user_id       integer
);

create index cs_support_rep_ticket_map_ticket_id_idx on cs_support_rep_ticket_map(ticket_id);
create index cs_support_rep_ticket_map_user_id_idx on cs_support_rep_ticket_map(user_id);
create index cs_support_rep_ticket_map_instance_id_idx on cs_support_rep_ticket_map(instance_id);

-- Answers question, who is automatically assigned by ticket of posted category
-- These are auxiliary assignments separate one from ones derived by cs_categories.property_label
-- This table started as cs_cat_assignment_map
CREATE TABLE cs_support_rep_cat_map (
       instance_id   integer,
       category_id   integer,
       -- one record for each category
       user_id       integer
       -- and / or references to a q-control roles for example.
       -- Multiple groups imply multiple rows. 
       -- No. This is too much complexity for use cases.
       -- This is handled via cs_categories.property_label and cs_support_rep_map.user_id
       -- group_ref    text
);
create index cs_support_rep_cat_map_instance_id_idx on cs_support_rep_cat_map(instance_id);
create index cs_support_rep_cat_map_category_id_idx on cs_support_rep_cat_map(category_id);
create index cs_support_rep_cat_map_user_id_idx on cs_support_rep_cat_map(user_id);

CREATE TABLE cs_contact_rep_cat_map (
       instance_id   integer,
       category_id   integer,
       -- one record for each category
       user_id       integer
       -- and / or references to a q-control roles for example.
       -- Multiple groups imply multiple rows. 
       -- No. This is too much complexity for use cases.
       -- This is handled via cs_categories.property_label and cs_contact_rep_cat_map.user_id
       -- group_ref    text
);
create index cs_contact_rep_cat_map_instance_id_idx on cs_contact_rep_cat_map(instance_id);
create index cs_contact_rep_cat_map_category_id_idx on cs_contact_rep_cat_map(category_id);
create index cs_contact_rep_cat_map_user_id_idx on cs_contact_rep_cat_map(user_id);


-- These get posted to cs_ticket_messages at time of trigger_ts
CREATE TABLE cs_sched_messages (
       instance_id    integer,
       ticket_id      integer not null,
       -- time to trigger/post message
       trigger_ts     timestamptz,
       -- triggered_p marked 1 after emails sent.
       -- marked 0 until then.
       triggered_p    varchar(1),
       message        text,
       -- See cs_tickets  for more details.
       privacy_level  varchar(1),
       -- html, text, etc
       message_type   varchar(4) default 'text'
);

create index cs_sched_messages_instance_id_idx on cs_sched_messages (instance_id);
create index cs_sched_messages_ticket_id_idx on cs_sched_messages (ticket_id);
create index cs_sched_messages_trigger_ts_idx on cs_sched_messages (trigger_ts);
create index cs_sched_messages_triggered_p_idx on cs_sched_messages (triggered_p);


-- This is for operations specific to a contact_id and ticket_id
CREATE TABLE cs_ticket_op_periods (
       instance_id    integer,
       ticket_id      integer not null,
       -- estimated, as in appointment time
       -- Between this period and when (op_done_p is 0 and/or ticket_id is open), 
       -- a message is shown to contact reps of cs_tickets.contact_id
       start_ts       timestamptz,
       end_ts         timestamptz,
       -- If support asks contact to make appointment.
       -- Support sets duration_*
       -- duration_name is text name of length of time to set aside in schedule
       duration_name  varchar(100),
       -- for calculating end_ts
       -- duration_name represented in seconds
       duration_s     integer,
       -- answers question:
       -- Is operation complete for this period?
       -- This closes if time is after end_time
       -- or ticket_id is closed.
       op_done_p      varchar(1)
);

create index cs_ticket_op_periods_instance_id_idx on cs_ticket_op_periods (instance_id);
create index cs_ticket_op_periods_ticket_id_idx on cs_ticket_op_periods (ticket_id);
create index cs_ticket_op_periods_op_done_p_idx on cs_ticket_op_periods (op_done_p);


