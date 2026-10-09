# คู่มือการติดตั้งและ Deploy ระบบขึ้น Cloudflare Pages & D1 Database
**ระบบระเบียนขอเข้าฝึกปฏิบัติงาน (Elective) — ศูนย์แพทยศาสตรศึกษาชั้นคลินิก โรงพยาบาลราชบุรี**

---

### โครงสร้างและไฟล์สำหรับการ Deploy บน Cloudflare
1. **`wrangler.toml`**: กำหนดค่า Cloudflare Pages, Node.js Compatibility, และการ Bind ฐานข้อมูล `DB` (Cloudflare D1)
2. **`schema.sql`**: สคริปต์สร้าง Table และข้อมูลตั้งต้นครบถ้วน (ผู้ใช้งาน, กลุ่มงาน, รายการคำขอฝึก, เอกสารแนบ, ประวัติการทำงาน)
3. **`deploy-cloudflare.ps1`**: สคริปต์รันคำสั่งอัตโนมัติบน PowerShell

---

### วิธีที่ 1: Deploy ผ่านคำสั่ง CLI (วิธีที่เร็วที่สุด)

1. เปิด PowerShell ที่โฟลเดอร์โปรเจกต์ `C:\Users\user\Desktop\WEBAPP`
2. ล็อกอินเข้าสู่ระบบ Cloudflare:
   ```powershell
   npx wrangler login
   ```
   *(หน้าเบราว์เซอร์จะเปิดขึ้นมา ให้กดปุ่ม **Allow** เพื่ออนุญาตสิทธิ์)*

3. สร้างฐานข้อมูล Cloudflare D1:
   ```powershell
   npx wrangler d1 create elective-db
   ```
   *หมายเหตุ: คัดลอก `database_id` ที่ได้มาใส่ในไฟล์ `wrangler.toml` แทนที่ `elective-db-ratchaburi`*

4. นำเข้า Schema และข้อมูลตั้งต้นเข้าฐานข้อมูล Cloudflare D1:
   ```powershell
   npx wrangler d1 execute elective-db --remote --file=./schema.sql
   ```

5. สั่ง Deploy ขึ้น Cloudflare Pages:
   ```powershell
   npx wrangler pages deploy .vercel/output/static --project-name ratchaburi-mec-elective
   ```

---

### วิธีที่ 2: Deploy ผ่าน Cloudflare Dashboard (ผ่าน Git / GitHub)

1. **อัปโหลดโปรเจกต์ขึ้น GitHub** (หรือ GitLab)
2. เข้าสู่ **[Cloudflare Dashboard](https://dash.cloudflare.com/)** > ไปที่เมนู **Workers & Pages** > **Create application** > แท็บ **Pages** > **Connect to Git**
3. เลือก Repository ของคุณ แล้วตั้งค่า Build settings ดังนี้:
   - **Framework preset**: `Next.js`
   - **Build command**: `npx @cloudflare/next-on-pages`
   - **Build output directory**: `.vercel/output/static`
   - **Environment variables**:
     - `NODE_VERSION` = `20`
4. **เชื่อมต่อ Cloudflare D1 Database**:
   - ไปที่แท็บ **Settings** > **Functions** > เลื่อนลงมาที่ **D1 database bindings**
   - คลิก **Add binding**:
     - **Variable name**: `DB`
     - **D1 database**: เลือก `elective-db`
5. คลิก **Save and Deploy** ระบบจะ Build และเปิดใช้งาน URL โฮสติ้งของ Cloudflare ทันที!

---

### ข้อมูลบัญชีผู้ใช้งานสำหรับเข้าสู่ระบบ (Production Accounts)

| ตำแหน่ง / หน้าที่ | ชื่อผู้ใช้งาน (Username) | รหัสผ่านเริ่มต้น | บทบาทในระบบ |
|---|---|---|---|
| ผู้อำนวยการศูนย์แพทย์ฯ | `admin` | `password123` | ผู้ดูแลระบบ (Admin) |
| หัวหน้างานบริหารการศึกษา | `supervisor` | `password123` | หัวหน้างาน (Supervisor) |
| นักวิชาการศึกษาชำนาญการ | `staff1` | `password123` | ทีมงาน (Staff) |
| เจ้าหน้าที่ประสานงานฝึกอบรม | `staff2` | `password123` | ทีมงาน (Staff) |
| นักวิเคราะห์นโยบายและแผน | `staff3` | `password123` | ทีมงาน (Staff) |
