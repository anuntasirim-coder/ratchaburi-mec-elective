# Script สำหรับ Deploy ระบบขึ้น Cloudflare Pages & Cloudflare D1
# ศูนย์แพทยศาสตรศึกษาชั้นคลินิก โรงพยาบาลราชบุรี

$env:Path = "$env:LOCALAPPDATA\Programs\nodejs;" + $env:Path

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Cloudflare Pages & D1 Deployment for Ratchaburi MEC" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. ตรวจสอบการ Login Cloudflare
Write-Host "`n[1/4] ตรวจสอบสถานะการเชื่อมต่อ Cloudflare..." -ForegroundColor Yellow
$whoami = npx wrangler whoami 2>&1
if ($whoami -match "You are not authenticated") {
    Write-Host "กรุณาเข้าสู่ระบบ Cloudflare ในเบราว์เซอร์ที่กำลังจะเปิดขึ้นมา..." -ForegroundColor Green
    npx wrangler login
}

# 2. สร้าง Cloudflare D1 Database (หากยังไม่มี)
Write-Host "`n[2/4] กำหนดค่า Cloudflare D1 Database (elective-db)..." -ForegroundColor Yellow
npx wrangler d1 create elective-db 2>$null

# 3. นำเข้า Schema และข้อมูลเริ่มต้นเข้าสู่ D1
Write-Host "`n[3/4] ติดตั้งฐานข้อมูลเริ่มต้นเข้าสู่ Cloudflare D1..." -ForegroundColor Yellow
npx wrangler d1 execute elective-db --remote --file=./schema.sql

# 4. Deploy หน้าเว็บขึ้น Cloudflare Pages
Write-Host "`n[4/4] Deploying Next.js to Cloudflare Pages..." -ForegroundColor Yellow
npx wrangler pages project create ratchaburi-mec-elective --production-branch main 2>$null
npx wrangler pages deploy .vercel/output/static --project-name ratchaburi-mec-elective

Write-Host "`n Deployment เสร็จสมบูรณ์แล้ว!" -ForegroundColor Green
Write-Host "คุณสามารถเปิดดู URL ที่ Cloudflare มอบให้ได้ทันที" -ForegroundColor Cyan
