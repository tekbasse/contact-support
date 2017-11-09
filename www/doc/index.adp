<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <h1>Contact Support Documentation</h1>

  <pre>(c) 2016 by Benjamin Brink
    po box 20, Marylhurst, OR 97036-0020 usa
    email: tekbasse@yahoo.com</pre>
  <p>Open source <a href="LICENSE.html">License under GNU GPL</a></p>
  <pre>
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see 
    <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a>.
  </pre>

  <h3>Contents</h3>
  <ul>
    <li>
      Documentation from original <a href="ecommerce-cs">ecommerce contact-support feature</a> (for reference only)
    </li><li>
      <a href="announcements">Announcements</a>
    </li><li>
      <a href="tickets">Tickets</a>
    <li><a href="sched-ops">Scheduled Operations</a></li>
    </li>
  </ul>

  <h3>features (requested)</h3>
  <h4>Ticket tracker</h4>
  <ul><li>
      tickets automatically alert to those assigned by tag/category or q-control package's company role.
    </li><li>
      replies to email notifications are posted to ticket.
    </li><li>
      Ticket state can be set identical (open/closed), or
      is somewhat independent between support team and contacts
      to allow for tickets that require contacts to complete
      tasks without additional coordination with cs reps.
      Here's a case where this feature could alleviate the dichotomy of a binary only solution: 
      <a href="https://github.com/isaacs/github/issues/583">https://github.com/isaacs/github/issues/583</a>.
      <pre>
        independent ticket state terminology:
        SST = support ticket state (open/closed)
        CST = contact ticket state (open/closed)
        When contact opens ticket, both CST and SST are opened for triage.
        When contact closes ticket, both CST and SST are closed.
        When support closes ticket, both CST and SST are closed
        When contact re-opens ticket or replies to ticket, ticket is triaged again by first tier.
        When support triages ticket, and more info needed by contact,
        ticket is SST is closed, CST remains open.
        When support triages new ticket, 
        qualified ticket remains open for both CST & SST.
        support categories and assigns ticket to a tier level and priority if different than default.
        When support triages a previously closed ticket,
        qualified ticket remains open for both CST & SST, and
        notifications sent to previously assigned reps.
        Otherwise SST is closed (with message sent to contact stating no support response needed).
        Contact asked to close CST ticket when they are finished with the topic internally.
      </pre>
    </li><li>
      URL to ticket or ticket/message
    </li><li>
      ticket thread has reference by ticket#/message# or ticket_nbr-message_nbr.
    </li><li>
      ticket number is unique alphanumeric reference to hide system ticket and message number, based on open timestamp.
    </li><li>
      create a feedback package to integrate reviews of support (later)
    </li><li>
      Show stats (avg/min/max) response time over day/week/year of contact as well as support to anticipate response timing.
    </li><li>
      Show stats (avg/min/max) time to final ticket closing to help anticipate total down/recovery time.
    </li><li>
      Show graph of UTC time-in-day and time-in-week when responses are made of contact as well as support to anticipate response timing.
    </li>
    <li>
      Schedule operations using ticket tracker. 
    <li> Active, scheduled operations appear on admin and contact's contact-support pages. 
    </li><li>
      Scheduled operations are associated with a ticket for logging and coordination
    </li><li>
      Notifications of active operations are expired when ticket closes, either by expire time 
      or manually by a cs rep.
    </li></li>
  </ul>
  <h4>Service announcements</h4>
  <ul>
    <li>
      Send announcement / notification to subset of contacts by contact_ref and/or user_ids. 
      For example, to announce on contact-support pages when specified users or contacts may be affected. 
    </li><li>
      Announcement may have a start time or expiration associated with it.
    </li><li>
      Present to specified contact_refs and/or user_ids or all. 
      For example, to minimize tickets associated with a system wide issue. 
      This kind of announcement is not registered in a contact's ticket logs.
    </li><li>
      Users have option to be notified when issue is resolved "click (button) to be notified.."
    </li>
  </ul>
  
