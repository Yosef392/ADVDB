SELECT 
    w.sid       AS waiting_sid,
    w.serial#   AS waiting_serial,
    w.username  AS waiting_user,
    w.status    AS waiting_status,
    
    '  <-- IS BLOCKED BY -->  ' AS direction,
    
    b.sid       AS blocking_sid,
    b.serial#   AS blocking_serial,
    b.username  AS blocking_user,
    b.status    AS blocking_status,
    
    w.event     AS wait_event
FROM 
    v$session w
JOIN 
    v$session b ON w.blocking_session = b.sid
WHERE 
    w.blocking_session IS NOT NULL;