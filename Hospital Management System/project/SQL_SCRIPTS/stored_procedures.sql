-- 1. Get appointments by doctor name
DELIMITER $$
CREATE PROCEDURE GetAppointmentsByDoctor(IN docName VARCHAR(100))
BEGIN
    SELECT docName AS Doctor, AppointmentID, PatientID, AppointmentDate, Status
    FROM Appointments
    WHERE DoctorID IN (
        SELECT DoctorID FROM Doctors WHERE Name = docName
    );
END$$
DELIMITER ;

--2. Find patients who have visited multiple times
DELIMITER $$
CREATE PROCEDURE GetFrequentPatients()
BEGIN
    SELECT PatientID, COUNT(*) AS no_of_visits
    FROM Appointments 
    GROUP BY PatientID 
    HAVING no_of_visits > 1;
END$$
DELIMITER ;

--3. Update appointment status after completion.
DELIMITER $$
CREATE PROCEDURE UpdateAppointmentStatus(
    IN p_appointment_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    UPDATE Appointments
    SET Status = p_new_status
    WHERE AppointmentID = p_appointment_id;
END $$
DELIMITER ;

--4. Get a list of doctors with the most appointments.
DELIMITER $$
CREATE PROCEDURE GetDoctorsWithMaxAppointments()
BEGIN
    WITH T AS (
        SELECT DoctorID, COUNT(*) AS no_of_appointments
        FROM Appointments
        GROUP BY DoctorID
    )
    SELECT * FROM T
    WHERE no_of_appointments = (SELECT MAX(no_of_appointments) FROM T);
END$$
DELIMITER ;

--5. Identify patients with critical conditions.
DELIMITER $$
CREATE PROCEDURE GetCriticalPatients()
BEGIN
    WITH T AS (
        SELECT PatientID
        FROM Appointments
        WHERE Status = 'Critical'
    )
    SELECT DISTINCT P.PatientID, P.Name, P.Age, P.Contact, P.Disease
    FROM Patients P
    INNER JOIN T ON P.PatientID = T.PatientID;
END$$
DELIMITER ;

--6. Retrieve appointments scheduled for the next week.
DELIMITER $$
CREATE PROCEDURE GetNextWeekAppointments()
BEGIN
    SELECT A.AppointmentID, A.PatientID, P.Name AS PatientName,
           A.DoctorID, D.Name AS DoctorName, A.AppointmentDate, A.Status
    FROM Appointments A
    JOIN Patients P ON A.PatientID = P.PatientID
    JOIN Doctors D ON A.DoctorID = D.DoctorID
    WHERE A.AppointmentDate BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
          AND A.Status = 'Scheduled';
END $$
DELIMITER ;

--7. Delete old patient records after five years.
DELIMITER $$
CREATE PROCEDURE DeleteOldPatients()
BEGIN
    DELETE FROM Appointments
    WHERE PatientID IN (
        SELECT pid FROM (
            SELECT P.PatientID AS pid
            FROM Patients P
            LEFT JOIN Appointments A ON P.PatientID = A.PatientID
            GROUP BY P.PatientID
            HAVING MAX(IFNULL(A.AppointmentDate, '1900-01-01')) < DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
        ) AS temp
    );
DELETE FROM Patients 
WHERE PatientID NOT IN (SELECT DISTINCT PatientID FROM Appointments);
END $$
DELIMITER ;

--8. Calculate the total number of patients treated in a month.
DELIMITER $$
CREATE PROCEDURE GetMonthlyAppointments(IN monthNum INT)
BEGIN
    SELECT monthNum AS Month, COUNT(*) AS no_of_patients
    FROM Appointments
    WHERE MONTH(AppointmentDate) = monthNum;
END$$
DELIMITER ;

--9. Find doctors available for emergency cases.
DELIMITER $$
CREATE PROCEDURE GetEmergencyDoctors()
BEGIN
    WITH T AS (
        SELECT DISTINCT DoctorID
        FROM Appointments
        WHERE Status = 'Emergency'
    )
    SELECT T.DoctorID, D.Name, D.Specialization, D.Contact
    FROM T
    INNER JOIN Doctors D ON T.DoctorID = D.DoctorID;
END$$
DELIMITER ;

--10. Retrieve patients with the same disease.
DELIMITER $$
CREATE PROCEDURE GetPatientsGroupedByDisease()
BEGIN
    SELECT Disease,
           GROUP_CONCAT(PatientID) AS PatientIDs
    FROM Patients
    GROUP BY Disease;
END$$
DELIMITER ;
