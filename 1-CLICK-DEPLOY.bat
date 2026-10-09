@echo off
chcp 65001 > nul
title Cloudflare Deployment - Ratchaburi MEC Elective
color 0b

echo ======================================================================
echo    ระบบระเบียนขอเข้าฝึกปฏิบัติงาน (Elective) - รพ.ราชบุรี
echo    One-Click Cloudflare Pages ^& D1 Database Deployment
echo ======================================================================
echo.

set "PATH=%LOCALAPPDATA%\Programs\nodejs;C:\Program Files\Git\cmd;C:\Program Files\Git\bin;C:\Program Files\Git\usr\bin;%PATH%"

echo [1/4] ตรวจสอบการเชื่อมต่อบัญชี Cloudflare...
npx wrangler whoami > nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo *****************************************************************
    echo  ระบบกำลังเปิดเบราว์เซอร์ กรุณากดปุ่ม "Allow" เพื่อเชื่อมต่อ Cloudflare
    echo *****************************************************************
    echo.
    npx wrangler login
)

echo.
echo [2/4] กำหนดค่าฐานข้อมูล Cloudflare D1 (elective-db)...
npx wrangler d1 create elective-db > nul 2>&1

echo.
echo [3/4] ติดตั้งตารางและข้อมูลเริ่มต้นลงสู่ Cloudflare D1 Database...
npx wrangler d1 execute elective-db --remote --file=./schema.sql -y

echo.
echo [4/4] กำลัง Build และ Deploy หน้าเว็บขึ้น Cloudflare Pages...
call npx @cloudflare/next-on-pages
call npx wrangler pages project create ratchaburi-mec-elective --production-branch main > nul 2>&1
call npx wrangler pages deploy .vercel/output/static --project-name ratchaburi-mec-elective

echo.
echo ======================================================================
echo  [สำเร็จ] เว็บไซต์ของคุณออนไลน์บน Cloudflare เรียบร้อยแล้ว!
echo ======================================================================
echo.
pause
