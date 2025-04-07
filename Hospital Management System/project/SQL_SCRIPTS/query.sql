CALL GetAppointmentsByDoctor('Dr. Iyer');
CALL GetFrequentPatients();
CALL UpdateAppointmentStatus(1002, 'Completed');
CALL GetDoctorsWithMaxAppointments();
CALL GetCriticalPatients();
CALL GetNextWeekAppointments();
CALL DeleteOldPatients();
CALL GetMonthlyAppointments(4); -- April
CALL GetEmergencyDoctors();
CALL GetPatientsGroupedByDisease();