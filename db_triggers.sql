-- ============================================================
-- New Trigger Functions for Trap Processing
-- 
-- These triggers handle:
-- 1. Updating ONT status when a trap is received
-- 2. Updating TAP status when ONT status changes
-- 3. Maintaining total_off count on TAPs
-- ============================================================

-- ============================================================
-- Function: update_ont_from_trap
-- Updates ONT status when a trap is inserted
-- ============================================================

CREATE OR REPLACE FUNCTION update_ont_from_trap()
RETURNS TRIGGER AS $$
DECLARE
    ont_found BOOLEAN := FALSE;
BEGIN
    -- Check if ONT exists with this serial number
    PERFORM 1 FROM onts WHERE serial = NEW.serial INTO ont_found;
    
    IF ont_found THEN
        -- Update the ONT: set status to down, record timestamp, mark as offline
        UPDATE onts
        SET 
            status = 'down',
            last_down_ts = NEW.timestamp,
            is_online = FALSE
        WHERE serial = NEW.serial;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Function: update_tap_from_ont
-- Updates TAP status when ONT status changes
-- ============================================================

CREATE OR REPLACE FUNCTION update_tap_from_ont()
RETURNS TRIGGER AS $$
DECLARE
    ont_count INT;
    tap_id_val INT;
    ont_exists BOOLEAN := FALSE;
BEGIN
    -- Verify the ONT still exists (in case it was deleted)
    PERFORM 1 FROM onts WHERE n_ontid = NEW.n_ontid INTO ont_exists;
    
    IF NOT ont_exists THEN
        RETURN NEW;
    END IF;
    
    -- Get the tap_id from the updated ONT
    SELECT tap_id INTO tap_id_val FROM onts WHERE n_ontid = NEW.n_ontid;
    
    -- Check if TAP exists
    PERFORM 1 FROM taps WHERE tap_id = tap_id_val;
    
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;
    
    -- Check if ONT is going down (status changed to 'down' OR is_online changed to FALSE)
    IF (NEW.status = 'down' AND OLD.status != 'down') OR 
       (NEW.is_online = FALSE AND OLD.is_online = TRUE) THEN
        
        -- Increment total_off for the TAP
        UPDATE taps
        SET total_off = total_off + 1
        WHERE tap_id = tap_id_val;
        
        -- Check if all ONTs on this TAP are now down
        SELECT COUNT(*) INTO ont_count 
        FROM onts 
        WHERE tap_id = tap_id_val AND (status = 'down' OR is_online = FALSE);
        
        -- If all ONTs are down, update TAP status
        IF ont_count = (SELECT COUNT(*) FROM onts WHERE tap_id = tap_id_val) THEN
            UPDATE taps 
            SET status = 'down' 
            WHERE tap_id = tap_id_val;
        END IF;
        
    -- Check if ONT is going up (status changed to 'up' OR is_online changed to TRUE)
    ELSIF (NEW.status = 'up' AND OLD.status != 'up') OR 
          (NEW.is_online = TRUE AND OLD.is_online = FALSE) THEN
        
        -- Decrement total_off for the TAP (don't go below 0)
        UPDATE taps
        SET total_off = GREATEST(total_off - 1, 0)
        WHERE tap_id = tap_id_val;
        
        -- Check if any ONTs are still down
        SELECT COUNT(*) INTO ont_count 
        FROM onts 
        WHERE tap_id = tap_id_val AND (status = 'down' OR is_online = FALSE);
        
        -- If no ONTs are down, update TAP status
        IF ont_count = 0 THEN
            UPDATE taps 
            SET status = 'up' 
            WHERE tap_id = tap_id_val;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Function: update_tap_status
-- Updates TAP status based on total_off count
-- ============================================================

CREATE OR REPLACE FUNCTION update_tap_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Update TAP status based on total_off count
    IF NEW.total_off > 0 THEN
        UPDATE taps 
        SET status = 'down' 
        WHERE tap_id = NEW.tap_id;
    ELSE
        UPDATE taps 
        SET status = 'up' 
        WHERE tap_id = NEW.tap_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Trigger: trg_trap_insert
-- Fires after a trap is inserted to update the corresponding ONT
-- ============================================================

CREATE TRIGGER trg_trap_insert
AFTER INSERT ON traps
FOR EACH ROW
EXECUTE FUNCTION update_ont_from_trap();


-- ============================================================
-- Trigger: trg_ont_status_update
-- Fires after ONT status changes to update the corresponding TAP
-- ============================================================

CREATE TRIGGER trg_ont_status_update
AFTER UPDATE ON onts
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status OR OLD.is_online IS DISTINCT FROM NEW.is_online)
EXECUTE FUNCTION update_tap_from_ont();


-- ============================================================
-- Trigger: trg_tap_status_update
-- Fires after TAP total_off changes to update TAP status
-- ============================================================

CREATE TRIGGER trg_tap_status_update
AFTER UPDATE ON taps
FOR EACH ROW
WHEN (OLD.total_off IS DISTINCT FROM NEW.total_off)
EXECUTE FUNCTION update_tap_status();


-- ============================================================
-- Additional Helper Function: reset_ont_status
-- Manual function to reset ONT status (for testing/recovery)
-- ============================================================

CREATE OR REPLACE FUNCTION reset_ont_status(p_serial VARCHAR)
RETURNS VOID AS $$
BEGIN
    UPDATE onts
    SET 
        status = 'up',
        is_online = TRUE,
        last_down_ts = NULL
    WHERE serial = p_serial;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Additional Helper Function: reset_tap_status
-- Manual function to reset TAP status (for testing)
-- ============================================================

CREATE OR REPLACE FUNCTION reset_tap_status(p_tap_id INT)
RETURNS VOID AS $$
BEGIN
    UPDATE taps
    SET 
        total_off = 0,
        status = 'up'
    WHERE tap_id = p_tap_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Example Usage / Testing
-- ============================================================

-- Insert a trap (this will trigger the cascade)
-- INSERT INTO traps (outage_id, timestamp, trap_type, host, position, serial, data)
-- VALUES (1, NOW(), 'ONT_DOWN', 'olt1.example.com', 'PON1/1/1', '123456789', 'Trap data');

-- Reset ONT status manually
-- SELECT reset_ont_status('123456789');

-- Reset TAP status manually
-- SELECT reset_tap_status(42);
