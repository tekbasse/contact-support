-- customer-service-create.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 3

 
create table cs_tickets (
    ticket_id           integer not null primary key,
    package_id          integer not null,
    customer_id         varchar(100),
    authenticated_by    varchar(40),
    ticket_category_id  varchar(100),
    subject             varchar(100),
    opened_by           integer,
    time_opened         timestamptz,
    time_closed         timestamptz not null,
    privacy_level       varchar(1),
    -- a number, 0 no privacy requirements
    --           5 requires ssl to see, no content via notifications
    --           9 don't show to anyone but submitter via ssl
    trashed_p            varchar(1)
);


create table cs_ticket_messages (
    post_id          integer not null primary key,
    package_id       integer not null,
    ticket_id        integer not null,
    post_time        timestamptz no null,
    message          text,
    internal_notes   text
    -- internal notes includes the values of variable_names_avail, if any;
    -- and actions, such as cgi vars passed in a form, as well
    -- as internal notes for ticket solvers etc.
);
        

create table cs_message_templates (
    template_id      integer not null primary key,
    package_id       integer not null,
    active_p         varchar(1),
    title            varchar(100),
    subject          varchar(200),
    variables        text,
    -- this lists the variable names that customer service can
    -- use in this particular email -- for info only
    message_content  text,
    last_modified    timestamptz not null,
    last_modified_by integer,
);

