-- ========================================================
-- Cloudflare D1 Schema for Elective Request Tracking System
-- ศูนย์แพทยศาสตรศึกษาชั้นคลินิก โรงพยาบาลราชบุรี
-- ========================================================

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS attachments;
DROP TABLE IF EXISTS requests;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;

-- 1. Users Table
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL CHECK(role IN ('admin', 'supervisor', 'staff')),
  title TEXT NOT NULL,
  department TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT NOT NULL,
  avatar TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. Departments Table
CREATE TABLE departments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact_person TEXT,
  phone TEXT,
  email TEXT
);

-- 3. Elective Requests Table
CREATE TABLE requests (
  id TEXT PRIMARY KEY,
  tracking_no TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  applicant_name TEXT NOT NULL,
  applicant_type TEXT NOT NULL CHECK(applicant_type IN ('extern', 'resident', 'fellow', 'medical_student', 'other')),
  institution TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  department_id TEXT NOT NULL,
  department_name TEXT NOT NULL,
  training_start_date TEXT NOT NULL,
  training_end_date TEXT NOT NULL,
  kanban_status TEXT NOT NULL DEFAULT 'new' CHECK(kanban_status IN ('new', 'sent_to_dept', 'waiting_response', 'accepted', 'rejected')),
  sent_to_dept_date TEXT,
  dept_response_date TEXT,
  response_status TEXT NOT NULL DEFAULT 'pending' CHECK(response_status IN ('pending', 'accepted', 'rejected')),
  assigned_staff_id TEXT,
  assigned_staff_name TEXT,
  remarks TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(id),
  FOREIGN KEY (assigned_staff_id) REFERENCES users(id)
);

-- 4. Attachments Table
CREATE TABLE attachments (
  id TEXT PRIMARY KEY,
  request_id TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  file_type TEXT NOT NULL,
  file_url TEXT NOT NULL,
  uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  uploaded_by TEXT NOT NULL,
  FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE
);

-- 5. Activity Logs Table
CREATE TABLE activity_logs (
  id TEXT PRIMARY KEY,
  request_id TEXT NOT NULL,
  action TEXT NOT NULL,
  performed_by TEXT NOT NULL,
  performed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  details TEXT,
  FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE
);

-- ========================================================
-- Seed Initial Data
-- ========================================================

-- Initial Users
INSERT INTO users (id, name, username, password, role, title, department, email, phone) VALUES
('u1', 'พว. รัตนาภรณ์ สมบูรณ์ทรัพย์', 'supervisor', 'password123', 'supervisor', 'หัวหน้างานบริหารแพทยศาสตรศึกษา', 'ศูนย์แพทยศาสตรศึกษาชั้นคลินิก', 'rattanaporn.s@rbh.moph.go.th', '032-719600 ต่อ 1102'),
('u2', 'น.ส. กัลยาณี เจริญผล', 'staff1', 'password123', 'staff', 'นักวิชาการศึกษาชำนาญการ', 'งานบริการการศึกษา ศูนย์แพทย์ฯ', 'kalyanee.c@rbh.moph.go.th', '081-445-6789'),
('u3', 'นาย ธนกร วงศ์วิริยะ', 'staff2', 'password123', 'staff', 'เจ้าหน้าที่ธุรการประสานงานฝึกอบรม', 'งานธุรการและสารบรรณ ศูนย์แพทย์ฯ', 'thanakorn.w@rbh.moph.go.th', '089-123-9876'),
('u4', 'น.ส. ศิริพร บุญสว่าง', 'staff3', 'password123', 'staff', 'นักวิเคราะห์นโยบายและแผน', 'งานพัฒนาคุณภาพการศึกษา', 'siriporn.b@rbh.moph.go.th', '086-778-9900'),
('u5', 'นพ. วิศรุต ปัญญาวงศ์', 'admin', 'password123', 'admin', 'ผู้อำนวยการศูนย์แพทยศาสตรศึกษาชั้นคลินิก', 'ศูนย์แพทยศาสตรศึกษาชั้นคลินิก', 'admin.mec@rbh.moph.go.th', '032-719600 ต่อ 1101');

-- Initial Departments (No doctor names, just clean department names and contact info)
INSERT INTO departments (id, name, contact_person, phone, email) VALUES
('dept-1', 'กลุ่มงานอายุรกรรม', 'ธุรการกลุ่มงานอายุรกรรม', '032-719600 ต่อ 2100', 'med@rbh.moph.go.th'),
('dept-2', 'กลุ่มงานศัลยกรรม', 'ธุรการกลุ่มงานศัลยกรรม', '032-719600 ต่อ 2200', 'surg@rbh.moph.go.th'),
('dept-3', 'กลุ่มงานสูติ-นรีเวชกรรม', 'ธุรการกลุ่มงานสูติ-นรีเวชกรรม', '032-719600 ต่อ 2300', 'obgyn@rbh.moph.go.th'),
('dept-4', 'กลุ่มงานกุมารเวชกรรม', 'ธุรการกลุ่มงานกุมารเวชกรรม', '032-719600 ต่อ 2400', 'peds@rbh.moph.go.th'),
('dept-5', 'กลุ่มงานออร์โธปิดิกส์', 'ธุรการกลุ่มงานออร์โธปิดิกส์', '032-719600 ต่อ 2500', 'ortho@rbh.moph.go.th'),
('dept-6', 'กลุ่มงานเวชศาสตร์ฉุกเฉิน', 'ธุรการกลุ่มงานเวชศาสตร์ฉุกเฉิน', '032-719600 ต่อ 2600', 'er@rbh.moph.go.th'),
('dept-7', 'กลุ่มงานวิสัญญีวิทยา', 'ธุรการกลุ่มงานวิสัญญีวิทยา', '032-719600 ต่อ 2700', 'anes@rbh.moph.go.th'),
('dept-8', 'กลุ่มงานจักษุวิทยา', 'ธุรการกลุ่มงานจักษุวิทยา', '032-719600 ต่อ 2800', 'eye@rbh.moph.go.th'),
('dept-9', 'กลุ่มงานโสต ศอ นาสิกวิทยา', 'ธุรการกลุ่มงาน ENT', '032-719600 ต่อ 2900', 'ent@rbh.moph.go.th'),
('dept-10', 'กลุ่มงานรังสีวิทยา', 'ธุรการกลุ่มงานรังสีวิทยา', '032-719600 ต่อ 2950', 'xray@rbh.moph.go.th');

-- Sample Elective Requests
INSERT INTO requests (id, tracking_no, title, description, applicant_name, applicant_type, institution, phone, department_id, department_name, training_start_date, training_end_date, kanban_status, sent_to_dept_date, dept_response_date, response_status, assigned_staff_id, assigned_staff_name, remarks) VALUES
('req-001', 'REQ-2567-001', 'ขอฝึกปฏิบัติงาน Elective เวชศาสตร์ฉุกเฉิน (Extern)', 'ขอเข้าฝึกการดูแลผู้ป่วยอุบัติเหตุและฉุกเฉิน Resuscitation และหัตถการฉุกเฉิน', 'นศพ. ภัทรพล สันติสุข', 'extern', 'คณะแพทยศาสตร์ จุฬาลงกรณ์มหาวิทยาลัย', '081-234-5678', 'dept-6', 'กลุ่มงานเวชศาสตร์ฉุกเฉิน', '2026-11-01', '2026-11-30', 'accepted', '2026-10-02', '2026-10-05', 'accepted', 'u2', 'คุณวรรณภา สุขสมบูรณ์', 'กลุ่มงานแจ้งว่ามีแพทย์พี่เลี้ยงพร้อมดูแล'),
('req-002', 'REQ-2567-002', 'ขอฝึกปฏิบัติงานอนุสาขาหัตถการหัวใจ Cath Lab', 'ฝึกปฏิบัติงานหัตถการสวนหัวใจและหลอดเลือด Coronary Angiography', 'พญ. นภัสสร วงศ์วิจิตร', 'fellow', 'คณะแพทยศาสตร์ศิริราชพยาบาล', '089-876-5432', 'dept-1', 'กลุ่มงานอายุรกรรม', '2026-12-01', '2026-12-31', 'waiting_response', '2026-10-04', NULL, 'pending', 'u2', 'คุณวรรณภา สุขสมบูรณ์', 'รอกรรมการอายุรกรรมพิจารณาจำนวนเตียงผู้ป่วยและห้องปฏิบัติการ'),
('req-003', 'REQ-2567-003', 'ขอเข้าฝึกทักษะการส่องกล้อง Laparoscopic Surgery', 'ฝึกปฏิบัติการผ่าตัดส่องกล้องถุงน้ำดีและไส้เลื่อนร่วมกับทีมศัลยแพทย์', 'นพ. วรเมธ กิตติพงษ์', 'resident', 'คณะแพทยศาสตร์ มหาวิทยาลัยเชียงใหม่', '084-555-1234', 'dept-2', 'กลุ่มงานศัลยกรรม', '2027-01-05', '2027-01-31', 'sent_to_dept', '2026-10-06', NULL, 'pending', 'u3', 'คุณธนภัทร วงศ์เจริญ', 'ส่งเอกสารบันทึกข้อความให้หัวหน้ากลุ่มงานศัลยกรรมแล้ว'),
('req-004', 'REQ-2567-004', 'ขอฝึกงาน Elective กุมารเวชกรรมทารกแรกเกิด (NICU)', 'ฝึกทักษะการดูแลทารกคลอดก่อนกำหนดและการใช้เครื่องช่วยหายใจชนิดพิเศษ', 'นศพ. กัญญาณัฐ พิพัฒน์ผล', 'extern', 'คณะแพทยศาสตร์ มหาวิทยาลัยธรรมศาสตร์', '086-789-0123', 'dept-4', 'กลุ่มงานกุมารเวชกรรม', '2026-11-15', '2026-12-15', 'new', NULL, NULL, 'pending', 'u4', 'คุณศิริพร บุญรักษา', 'เอกสารครบถ้วน รอส่งบันทึกข้อความถึงกลุ่มงานกุมารเวชกรรม'),
('req-005', 'REQ-2567-005', 'ขอฝึกปฏิบัติงานการผ่าตัดเปลี่ยนข้อเข่าเทียม (Arthroplasty)', 'ศึกษาและสังเกตการณ์การผ่าตัด Total Knee Arthroplasty', 'นพ. ธนกฤต ชัยชนะ', 'resident', 'คณะแพทยศาสตร์ มหาวิทยาลัยขอนแก่น', '083-999-8877', 'dept-5', 'กลุ่มงานออร์โธปิดิกส์', '2026-10-15', '2026-11-15', 'rejected', '2026-09-28', '2026-10-03', 'rejected', 'u3', 'คุณธนภัทร วงศ์เจริญ', 'กลุ่มงานตอบกลับว่าช่วงเวลาดังกล่าวมี Resident ประจำบ้านเต็มโควตาแล้ว');

-- Sample Attachments
INSERT INTO attachments (id, request_id, file_name, file_size, file_type, file_url, uploaded_by) VALUES
('att-001', 'req-001', 'หนังสือขอความอนุเคราะห์_จุฬาฯ.pdf', 524288, 'application/pdf', '/uploads/mock/chula_request.pdf', 'คุณวรรณภา สุขสมบูรณ์'),
('att-002', 'req-001', 'ประวัติและผลการเรียน_CV.pdf', 314572, 'application/pdf', '/uploads/mock/transcript_cv.pdf', 'คุณวรรณภา สุขสมบูรณ์'),
('att-003', 'req-002', 'หนังสือรับรองต้นสังกัด_ศิริราช.pdf', 419430, 'application/pdf', '/uploads/mock/siriraj_cert.pdf', 'คุณวรรณภา สุขสมบูรณ์');

-- Sample Activity Logs
INSERT INTO activity_logs (id, request_id, action, performed_by, details) VALUES
('act-001', 'req-001', 'สร้างคำขอเข้าฝึกปฏิบัติงาน', 'คุณวรรณภา สุขสมบูรณ์', 'สร้างคำขอใหม่ REQ-2567-001'),
('act-002', 'req-001', 'ส่งเอกสารให้กลุ่มงาน', 'คุณวรรณภา สุขสมบูรณ์', 'ส่งบันทึกข้อความให้กลุ่มงานเวชศาสตร์ฉุกเฉิน'),
('act-003', 'req-001', 'กลุ่มงานตอบรับ', 'คุณวรรณภา สุขสมบูรณ์', 'กลุ่มงานตอบรับเข้าฝึกปฏิบัติงาน เรียบร้อยแล้ว');
