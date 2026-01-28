-- ============================================================
-- fn_check_correlation
-- Vérifie si les ONTs d'un tap sont tombés dans la fenêtre de 30 secondes
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_correlation(p_tap_id INT)
RETURNS VOID AS $$
DECLARE
    v_min_ts      TIMESTAMP;
    v_max_ts      TIMESTAMP;
    v_count_down  INT;
BEGIN
    -- Get timestamp range and count of down ONTs for this tap
    SELECT 
        MIN(last_down_ts),
        MAX(last_down_ts),
        COUNT(*)
    INTO 
        v_min_ts,
        v_max_ts,
        v_count_down
    FROM ont
    WHERE tap_id = p_tap_id
      AND status = 'down'
      AND last_down_ts IS NOT NULL;

    -- Need at least 2 ONTs down to correlate
    IF v_count_down < 2 THEN
        RETURN;
    END IF;

    -- Check if all down ONTs fell within 30-second window
    IF (v_max_ts - v_min_ts) <= INTERVAL '30 seconds' THEN
        -- Correlated outage confirmed - increment outage_off
        UPDATE tap
        SET outage_off = outage_off + 1
        WHERE tap_id = p_tap_id;
    END IF;

END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- Alternative version with more detail (returns info instead of void)
-- Plus détaillé - returns what happened
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_correlation_verbose(p_tap_id INT)
RETURNS TABLE (
    tap_id          INT,
    onts_down       INT,
    min_timestamp   TIMESTAMP,
    max_timestamp   TIMESTAMP,
    time_spread     INTERVAL,
    is_correlated   BOOLEAN,
    action_taken    TEXT
) AS $$
DECLARE
    v_min_ts      TIMESTAMP;
    v_max_ts      TIMESTAMP;
    v_count_down  INT;
    v_spread      INTERVAL;
    v_correlated  BOOLEAN := FALSE;
    v_action      TEXT := 'none';
BEGIN
    -- Get timestamp range and count
    SELECT 
        MIN(o.last_down_ts),
        MAX(o.last_down_ts),
        COUNT(*)
    INTO 
        v_min_ts,
        v_max_ts,
        v_count_down
    FROM ont o
    WHERE o.tap_id = p_tap_id
      AND o.status = 'down'
      AND o.last_down_ts IS NOT NULL;

    -- Calculate spread
    v_spread := v_max_ts - v_min_ts;

    -- Evaluate correlation
    IF v_count_down >= 2 AND v_spread <= INTERVAL '30 seconds' THEN
        v_correlated := TRUE;
        
        -- Increment outage_off counter
        UPDATE tap t
        SET outage_off = outage_off + 1
        WHERE t.tap_id = p_tap_id;
        
        v_action := 'outage_off incremented';
    ELSIF v_count_down < 2 THEN
        v_action := 'insufficient ONTs down';
    ELSE
        v_action := 'outside 30s window';
    END IF;

    -- Return the results
    RETURN QUERY SELECT 
        p_tap_id,
        v_count_down,
        v_min_ts,
        v_max_ts,
        v_spread,
        v_correlated,
        v_action;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- The trigger that calls it
-- Le déclencheur qui appelle la fonction
-- ============================================================

CREATE OR REPLACE FUNCTION trg_tap_evaluate_fn()
RETURNS TRIGGER AS $$
BEGIN
    -- Only evaluate when total_off increases to 2 or more
    IF NEW.total_off >= 2 AND (OLD.total_off IS NULL OR OLD.total_off < 2) THEN
        PERFORM fn_check_correlation(NEW.tap_id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tap_evaluate
    AFTER UPDATE OF total_off ON tap
    FOR EACH ROW
    EXECUTE FUNCTION trg_tap_evaluate_fn();


-- ============================================================
-- Example usage / Test
-- ============================================================

-- Check correlation for tap 42
-- SELECT fn_check_correlation(42);

-- Or with verbose output to see what happened
-- SELECT * FROM fn_check_correlation_verbose(42);

-- Output example:
-- tap_id | onts_down | min_timestamp       | max_timestamp       | time_spread | is_correlated | action_taken
-- -------+-----------+---------------------+---------------------+-------------+---------------+---------------------
--     42 |         3 | 2024-01-15 10:30:01 | 2024-01-15 10:30:18 | 00:00:17    | true          | outage_off incremented
