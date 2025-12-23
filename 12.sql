
SHOW USER;

SET LINESIZE 200
COL WAITING_USER FORMAT A15
COL BLOCKING_USER FORMAT A15
COL EVENT FORMAT A30

SELECT 
    -- Information about the WAITING session (User 2)
    w.sid       AS waiting_sid,
    w.serial#   AS waiting_serial,
    w.username  AS waiting_user,
    w.status    AS waiting_status,
    
    '  <-- IS BLOCKED BY -->  ' AS direction,
    
    -- Information about the BLOCKING session (User 1)
    b.sid       AS blocking_sid,
    b.serial#   AS blocking_serial,
    b.username  AS blocking_user,
    b.status    AS blocking_status,
    
    -- What is the waiter waiting for?
    w.event     AS wait_event
FROM 
    v$session w
JOIN 
    v$session b ON w.blocking_session = b.sid
WHERE 
    w.blocking_session IS NOT NULL;