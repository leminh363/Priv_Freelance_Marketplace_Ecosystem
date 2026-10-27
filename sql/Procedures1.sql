DELIMITER //
CREATE PROCEDURE sp_submit_proposal (
  IN  p_job_id          BIGINT,
  IN  p_freelancer_id   BIGINT,
  IN  p_payment_type_id BIGINT,
  IN  p_payment_amount  DECIMAL(10,2),
  OUT p_proposal_id     BIGINT
)
BEGIN
  DECLARE v_pending_id BIGINT;

  SELECT id INTO v_pending_id
  FROM status_catalog
  WHERE status_name = 'Pending';

  IF EXISTS (SELECT 1 FROM proposal
             WHERE job_id = p_job_id
               AND freelancer_id = p_freelancer_id
               AND current_proposal_status_id = v_pending_id) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Freelancer already has a pending proposal for this job';
  END IF;

  INSERT INTO proposal (job_id, freelancer_id, payment_type_id,
                        payment_amount, current_proposal_status_id)
  VALUES (p_job_id, p_freelancer_id, p_payment_type_id,
          p_payment_amount, v_pending_id);

  SET p_proposal_id = LAST_INSERT_ID();
END //
DELIMITER ;