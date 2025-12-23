UPDATE User1.Rooms
SET availability = 'Full'
WHERE type = 'General';

ROLLBACK;
