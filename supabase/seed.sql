-- DJIHS Management System: sample data
-- Run after schema.sql on an empty database.
--
-- Logins (username / password):
--   admin                    / admin123    registrar
--   maria.santos@djihs.edu.ph / teacher123  key teacher
--   jose.reyes@djihs.edu.ph   / teacher123  subject teacher  (same for the other teachers)

begin;

-- ---------------------------------------------------------------------------
-- School year. The report pages hard-code sy_id 1 = '2025-26'.
-- ---------------------------------------------------------------------------
insert into public.schoolyears (sy_id, yearrange) values
  (1, '2025-26');

-- ---------------------------------------------------------------------------
-- Global config. Deadlines are relative to the seed date so grade entry is open.
-- ---------------------------------------------------------------------------
insert into public.system_config (id, active_sy, q1_deadline, q2_deadline, q3_deadline, q4_deadline, is_editing_enabled) values
  (1, '2025-26', current_date + 30, current_date + 90, current_date + 150, current_date + 210, true);

-- ---------------------------------------------------------------------------
-- Teachers
-- ---------------------------------------------------------------------------
insert into public.teachers (teacherid, firstname, lastname, email, phone) values
  (1, 'Maria',  'Santos',   'maria.santos@djihs.edu.ph',   '09171234501'),
  (2, 'Jose',   'Reyes',    'jose.reyes@djihs.edu.ph',     '09171234502'),
  (3, 'Ana',    'Cruz',     'ana.cruz@djihs.edu.ph',       '09171234503'),
  (4, 'Ramon',  'Garcia',   'ramon.garcia@djihs.edu.ph',   '09171234504'),
  (5, 'Liza',   'Mendoza',  'liza.mendoza@djihs.edu.ph',   '09171234505'),
  (6, 'Carlo',  'Bautista', 'carlo.bautista@djihs.edu.ph', '09171234506');

-- ---------------------------------------------------------------------------
-- Users. Roles are lowercase because login, the sidebar and RoleGuard compare
-- against 'registrar' / 'key teacher' / 'subject teacher'.
-- admin123   -> $2b$10$f2IDBxDeQQn/9jz2YQ3cJ.pR8fy2Qba8MBi9NXSx6oXPQKLBwupiK
-- teacher123 -> $2b$10$n81GjYMTPy7ehhCdRtzCc.xb6OR7h98Lr9DBZgT/mLjNIss4To13u
-- ---------------------------------------------------------------------------
insert into public.users (username, password, role, first_name, last_name, email, phone) values
  ('admin', '$2b$10$f2IDBxDeQQn/9jz2YQ3cJ.pR8fy2Qba8MBi9NXSx6oXPQKLBwupiK', 'registrar', 'School', 'Registrar', null, null);

insert into public.users (username, password, role, first_name, last_name, email, phone)
select t.email,
       '$2b$10$n81GjYMTPy7ehhCdRtzCc.xb6OR7h98Lr9DBZgT/mLjNIss4To13u',
       case when t.teacherid = 1 then 'key teacher' else 'subject teacher' end,
       t.firstname, t.lastname, t.email, t.phone
from public.teachers t;

-- ---------------------------------------------------------------------------
-- Sections: two per grade level. Grade 10 sections have no adviser yet.
-- ---------------------------------------------------------------------------
insert into public.sections (sectionid, sectionname, gradelevel, adviserid, status) values
  (1, 'Sampaguita', 7,  2,    'Active'),
  (2, 'Rosal',      7,  3,    'Active'),
  (3, 'Narra',      8,  4,    'Active'),
  (4, 'Molave',     8,  5,    'Active'),
  (5, 'Rizal',      9,  6,    'Active'),
  (6, 'Bonifacio',  9,  1,    'Active'),
  (7, 'Mabini',     10, null, 'Active'),
  (8, 'Luna',       10, null, 'Active');

-- ---------------------------------------------------------------------------
-- Subjects: the eight JHS learning areas for each grade (codes like MATH7).
-- ---------------------------------------------------------------------------
insert into public.subjects (subjectcode, subjectname, intendedgradelevel)
select s.prefix || g.lvl, s.name, g.lvl
from (values
        ('FIL',   'Filipino'),
        ('ENG',   'English'),
        ('MATH',  'Mathematics'),
        ('SCI',   'Science'),
        ('AP',    'Araling Panlipunan'),
        ('ESP',   'Edukasyon sa Pagpapakatao'),
        ('TLE',   'Technology and Livelihood Education'),
        ('MAPEH', 'MAPEH')
     ) as s(prefix, name)
cross join (values (7), (8), (9), (10)) as g(lvl);

-- ---------------------------------------------------------------------------
-- Classes: six subjects per section, one teacher per learning area.
-- TLE and MAPEH are left unassigned so the Assign Subjects flow has work to do.
-- ---------------------------------------------------------------------------
insert into public.classes (subjectcode, teacherid, sectionid, schedule)
select a.prefix || sec.gradelevel, a.teacherid, sec.sectionid, a.schedule
from public.sections sec
cross join (values
        ('ESP',  1, 'MWF 7:30-8:30 AM'),
        ('ENG',  2, 'MWF 8:30-9:30 AM'),
        ('MATH', 3, 'TTh 7:30-9:00 AM'),
        ('SCI',  4, 'TTh 9:00-10:30 AM'),
        ('FIL',  5, 'MWF 10:00-11:00 AM'),
        ('AP',   6, 'MWF 1:00-2:00 PM')
     ) as a(prefix, teacherid, schedule)
order by sec.sectionid, a.teacherid;

-- ---------------------------------------------------------------------------
-- Students: three per section, all enrolled in SY 2025-26.
-- ---------------------------------------------------------------------------
insert into public.students (lrn, firstname, lastname, middleinitial, birthday, address, email, gender, sectionid) values
  ('136512250001', 'Juan',      'Dela Cruz',  'P', '2013-03-14', 'Brgy. San Jose, Rodriguez, Rizal',  'juan.delacruz@student.djihs.edu.ph',   'Male',   1),
  ('136512250002', 'Angela',    'Villanueva', 'M', '2013-07-22', 'Brgy. Burgos, Rodriguez, Rizal',    'angela.villanueva@student.djihs.edu.ph','Female', 1),
  ('136512250003', 'Mark',      'Aquino',     'R', '2013-01-05', 'Brgy. San Jose, Rodriguez, Rizal',  'mark.aquino@student.djihs.edu.ph',     'Male',   1),
  ('136512250004', 'Kristine',  'Ramos',      'L', '2013-09-30', 'Brgy. Manggahan, Rodriguez, Rizal', 'kristine.ramos@student.djihs.edu.ph',  'Female', 2),
  ('136512250005', 'Paolo',     'Navarro',    'S', '2013-05-18', 'Brgy. Burgos, Rodriguez, Rizal',    'paolo.navarro@student.djihs.edu.ph',   'Male',   2),
  ('136512250006', 'Bea',       'Castillo',   'A', '2013-11-02', 'Brgy. Geronimo, Rodriguez, Rizal',  'bea.castillo@student.djihs.edu.ph',    'Female', 2),
  ('136512240007', 'Miguel',    'Torres',     'D', '2012-02-11', 'Brgy. San Jose, Rodriguez, Rizal',  'miguel.torres@student.djihs.edu.ph',   'Male',   3),
  ('136512240008', 'Camille',   'Flores',     'B', '2012-06-25', 'Brgy. Manggahan, Rodriguez, Rizal', 'camille.flores@student.djihs.edu.ph',  'Female', 3),
  ('136512240009', 'Rafael',    'Domingo',    'C', '2012-10-08', 'Brgy. Burgos, Rodriguez, Rizal',    'rafael.domingo@student.djihs.edu.ph',  'Male',   3),
  ('136512240010', 'Jasmine',   'Pascual',    'E', '2012-04-17', 'Brgy. Geronimo, Rodriguez, Rizal',  'jasmine.pascual@student.djihs.edu.ph', 'Female', 4),
  ('136512240011', 'Luis',      'Salazar',    'F', '2012-08-03', 'Brgy. San Jose, Rodriguez, Rizal',  'luis.salazar@student.djihs.edu.ph',    'Male',   4),
  ('136512240012', 'Patricia',  'Mercado',    'G', '2012-12-21', 'Brgy. Burgos, Rodriguez, Rizal',    'patricia.mercado@student.djihs.edu.ph','Female', 4),
  ('136512230013', 'Gabriel',   'Lopez',      'H', '2011-03-09', 'Brgy. Manggahan, Rodriguez, Rizal', 'gabriel.lopez@student.djihs.edu.ph',   'Male',   5),
  ('136512230014', 'Nicole',    'Gonzales',   'I', '2011-07-14', 'Brgy. San Jose, Rodriguez, Rizal',  'nicole.gonzales@student.djihs.edu.ph', 'Female', 5),
  ('136512230015', 'Adrian',    'Fernandez',  'J', '2011-11-27', 'Brgy. Geronimo, Rodriguez, Rizal',  'adrian.fernandez@student.djihs.edu.ph','Male',   5),
  ('136512230016', 'Sofia',     'Rivera',     'K', '2011-01-19', 'Brgy. Burgos, Rodriguez, Rizal',    'sofia.rivera@student.djihs.edu.ph',    'Female', 6),
  ('136512230017', 'Daniel',    'Morales',    'N', '2011-05-06', 'Brgy. San Jose, Rodriguez, Rizal',  'daniel.morales@student.djihs.edu.ph',  'Male',   6),
  ('136512230018', 'Isabel',    'Tolentino',  'O', '2011-09-12', 'Brgy. Manggahan, Rodriguez, Rizal', 'isabel.tolentino@student.djihs.edu.ph','Female', 6),
  ('136512220019', 'Joshua',    'Santiago',   'Q', '2010-02-28', 'Brgy. Geronimo, Rodriguez, Rizal',  'joshua.santiago@student.djihs.edu.ph', 'Male',   7),
  ('136512220020', 'Andrea',    'Valdez',     'T', '2010-06-07', 'Brgy. San Jose, Rodriguez, Rizal',  'andrea.valdez@student.djihs.edu.ph',   'Female', 7),
  ('136512220021', 'Kevin',     'Manalo',     'U', '2010-10-15', 'Brgy. Burgos, Rodriguez, Rizal',    'kevin.manalo@student.djihs.edu.ph',    'Male',   7),
  ('136512220022', 'Hannah',    'Ocampo',     'V', '2010-04-23', 'Brgy. Manggahan, Rodriguez, Rizal', 'hannah.ocampo@student.djihs.edu.ph',   'Female', 8),
  ('136512220023', 'Christian', 'Soriano',    'W', '2010-08-31', 'Brgy. Geronimo, Rodriguez, Rizal',  'christian.soriano@student.djihs.edu.ph','Male',  8),
  ('136512220024', 'Danica',    'Aguilar',    'Y', '2010-12-10', 'Brgy. San Jose, Rodriguez, Rizal',  'danica.aguilar@student.djihs.edu.ph',  'Female', 8);

insert into public.enrollments (lrn, sectionid, sy_id, gradelevel, status)
select st.lrn, st.sectionid, 1, sec.gradelevel, 'Enrolled'
from public.students st
join public.sections sec on sec.sectionid = st.sectionid
order by st.lrn;

-- ---------------------------------------------------------------------------
-- Q1 grades for every class (deterministic pseudo-random 72-99 scores).
-- final = 40% written work + 60% performance task, matching GradeEntryClient.
-- ---------------------------------------------------------------------------
insert into public.grades (enrollmentid, classid, quarter, writtenwork, performancetask, finalgrade, remarks)
select e.enrollmentid, c.classid, 1, s.ww, s.pt,
       round(s.ww * 0.4 + s.pt * 0.6, 2),
       case when s.ww * 0.4 + s.pt * 0.6 >= 75 then 'PASSED' else 'FAILED' end
from public.enrollments e
join public.classes c on c.sectionid = e.sectionid
cross join lateral (
  select 72 + abs(hashtext(e.lrn || ':ww:' || c.classid)) % 28 as ww,
         72 + abs(hashtext(e.lrn || ':pt:' || c.classid)) % 28 as pt
) s;

-- Q1 workflow state: grades 7-8 forwarded and verified, grade 9 forwarded and
-- awaiting the key teacher, grade 10 not yet submitted.
update public.classes c
set q1_submission_status = 'forwarded',
    q1_status = 'completed',
    last_submitted = now() - interval '20 days'
from public.sections sec
where sec.sectionid = c.sectionid and sec.gradelevel in (7, 8);

update public.classes c
set q1_submission_status = 'forwarded',
    last_submitted = now() - interval '3 days'
from public.sections sec
where sec.sectionid = c.sectionid and sec.gradelevel = 9;

-- ---------------------------------------------------------------------------
-- Monthly attendance, Aug-Nov.
-- ---------------------------------------------------------------------------
insert into public.attendance (enrollmentid, month, dayspresent, totalschooldays)
select e.enrollmentid, m.month,
       m.days - abs(hashtext(e.lrn || m.month)) % 4,
       m.days
from public.enrollments e
cross join (values ('August', 21), ('September', 22), ('October', 23), ('November', 20)) as m(month, days);

-- ---------------------------------------------------------------------------
-- Audit trail starter row
-- ---------------------------------------------------------------------------
insert into public.audit_logs (action, performed_by_name, details) values
  ('SEED', 'System', 'Database seeded with sample data for SY 2025-26.');

-- ---------------------------------------------------------------------------
-- Move identity sequences past the explicit ids used above.
-- ---------------------------------------------------------------------------
select setval(pg_get_serial_sequence('public.schoolyears', 'sy_id'),     (select max(sy_id)     from public.schoolyears));
select setval(pg_get_serial_sequence('public.teachers',    'teacherid'), (select max(teacherid) from public.teachers));
select setval(pg_get_serial_sequence('public.sections',    'sectionid'), (select max(sectionid) from public.sections));

commit;
