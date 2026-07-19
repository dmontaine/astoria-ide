-- TestPlan A3 -- one-time server setup, run by the owner, not by the test.
--
-- Creates a database and a user scoped to it and nothing else. The test drops and recreates its
-- own tables on every run, so it needs real DDL rights -- but only inside astoria_test, which is
-- why this grants on `astoria_test`.* rather than *.*. If the test ever goes wrong, the blast
-- radius is one throwaway database.
--
-- Run as root, choosing your own password in place of CHANGE_ME:
--
--   "C:\Program Files\MariaDB 12.3\bin\mysql.exe" -u root -p < setup_astoria_test.sql
--
-- then tell the test where to look, in the SAME shell you run it from:
--
--   set MARIADB_TEST_PASSWORD=the password you chose
--
-- The password is never written into a source file and never committed.

CREATE DATABASE IF NOT EXISTS astoria_test
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- utf8mb4 deliberately: the test writes non-ASCII text to prove the control's UTF-8 conversion
-- survives a round trip, and utf8mb3 would silently mangle anything outside the BMP.

CREATE USER IF NOT EXISTS 'astoria_test'@'localhost' IDENTIFIED BY 'CHANGE_ME';

GRANT ALL PRIVILEGES ON astoria_test.* TO 'astoria_test'@'localhost';

FLUSH PRIVILEGES;

SELECT 'astoria_test database and user are ready' AS status;
