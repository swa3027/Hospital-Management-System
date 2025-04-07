DELETE FROM Appointments
WHERE Status='Cancelled';

DELETE FROM Patients 
WHERE PatientID NOT IN (SELECT DISTINCT PatientID FROM Appointments);
