cls
@ECHO OFF & CD /D %~DP0 & TITLE ��װ VMware Workstation ����
>NUL 2>&1 REG.exe query "HKU\S-1-5-19" || (
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\Getadmin.vbs"
    ECHO UAC.ShellExecute "%~f0", "%1", "", "runas", 1 >> "%TEMP%\Getadmin.vbs"
    "%TEMP%\Getadmin.vbs"
    DEL /f /q "%TEMP%\Getadmin.vbs" 2>NUL
    Exit /b
)
set vmbit=
if /i %PROCESSOR_IDENTIFIER:~0,3% neq x86 set vmbit=64

:menu
cd /d "%~dp0"
cls
echo.
echo          �������ط���װ ���˵�
echo         ===========================
echo.
echo         0��һ����װ���з���(USB��Hostd�������ӡ�����������ⰲװ)
echo         1�����繦��
echo         2��USB�豸֧�ַ���
echo         3������ӳ�书��
echo         4�������ӡ������
echo         5�������������Զ�̷��ʷ���(Hostd����)
echo         6����װ��ǿ�����������
echo         7����������ϵͳ������ΪӢ�Ľ���
echo         8����װ�����Ⲣ����install.log��־(�����Ŵ�)
echo         e����   ��
echo.
echo         ��ʾ��0-6���װ��ȫ�����ü�Ϊ��Сģʽ
:cl
echo.
set /p choice=         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="0" goto s0
if /i "%choice%"=="1" goto s1
if /i "%choice%"=="2" goto s2
if /i "%choice%"=="3" goto s3
if /i "%choice%"=="4" goto s4
if /i "%choice%"=="5" goto s5
if /i "%choice%"=="6" goto s6
if /i "%choice%"=="7" goto s7
if /i "%choice%"=="8" goto chkinfo
if /i "%choice%"=="e" goto EX

echo.
echo         ѡ����Ч������������
echo.
goto cl

:s0
echo.
set /p no=         ���ٴ�ȷ���Ƿ�װȫ������ Y(��ʼ��װ)�� N(�˳���װ)��
echo.
if /I "%no%"=="y" goto ks
if /I "%no%"=="n" exit
echo         �����������������...
goto s0cl
:ks
cls
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul&&(echo.&echo ����ж�ظɾ��ٰ�װ!!!&pause>nul&goto MENU)
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >nul 2>nul&&(echo.&echo ����ж�ظɾ��ٰ�װ!!!&pause>nul&goto MENU)
echo.
echo         ���ڰ�װ�����Ժ�...
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >nul 2>nul || (vnetlib%vmbit%.exe -- install userif)
start /wait vnetlib%vmbit%.exe -- install adapter
start /wait vnetlib%vmbit%.exe -- install bridge
start /wait vnetlib%vmbit%.exe -- start bridge

start /wait vnetlib.exe -- install dhcp
start /wait vnetlib.exe -- start dhcp

net start Dhcp >nul 2>nul

start /wait vnetlib.exe -- add adapter vmnet1
start /wait vnetlib.exe -- add dhcp vmnet1
start /wait vnetlib.exe -- set vnet vmnet1 addr 10.10.10.0
start /wait vnetlib.exe -- stop dhcp
start /wait vnetlib.exe -- update dhcp vmnet1
start /wait vnetlib.exe -- start dhcp
start /wait vnetlib.exe -- update adapter vmnet1

start /wait vnetlib.exe -- install nat

start /wait vnetlib.exe -- add adapter vmnet8
start /wait vnetlib.exe -- add dhcp vmnet8
start /wait vnetlib.exe -- add nat vmnet8
start /wait vnetlib.exe -- set vnet vmnet8 addr 192.168.128.0
start /wait vnetlib.exe -- stop nat
start /wait vnetlib.exe -- stop dhcp
start /wait vnetlib.exe -- update dhcp vmnet8
start /wait vnetlib.exe -- start dhcp
start /wait vnetlib.exe -- update nat vmnet8
start /wait vnetlib.exe -- start nat
start /wait vnetlib.exe -- update adapter vmnet8

copy /y .\vstor2*.sys "%WinDir%\SysWOW64\drivers\" >nul 2>nul
sc create vstor2-mntapi20-shared type= kernel start= auto binpath= "SysWOW64\drivers\vstor2-mntapi20-shared.sys" displayname= "Vstor2 MntApi 2.0 Driver (shared)"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\vstor2-mntapi20-shared" /v WOW64 /t REG_DWORD /d "0x00000001" /f
net start vstor2-mntapi20-shared >nul

echo.
echo         һ����װ���з���ɹ���������������˵�
echo         ��Ҳ�������˵���ѡ����ò���Ҫ�ķ���
pause >nul
goto menu

:s1
cls
echo.
echo                �������˵�
echo         ==========================
echo.
echo         1��bridge(�Ž�)
echo.
echo         2��nat(���繲��)
echo.
echo         3��host-only(��Ϊ����)
echo.
echo         4������VMnetDHCP����(������������)
echo.
echo         5������VMnetDHCP����(������������)
echo.
echo         6. ����ȫ�����繦��
echo.
echo         7���������˵�
echo.
echo  ��ܰ��ʾ:
echo          ��Ҫ��δ����ϵͳʱ�������û�ͣ��ĳ���������
:cl1
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n1
if /i "%choice%"=="2" goto n2
if /i "%choice%"=="3" goto n3
if /i "%choice%"=="4" goto n4
if /i "%choice%"=="5" goto n5
if /i "%choice%"=="6" goto n6
if /i "%choice%"=="7" goto menu
echo.
echo         ѡ����Ч������������
echo.
goto cl1

:n1
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1�������Žӷ���
echo.
echo         2�������Žӷ���
echo.
echo         3�������������˵�
echo.
echo.
:cl11
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n11
if /i "%choice%"=="2" goto n12
if /i "%choice%"=="3" goto s1
echo.
echo         ѡ����Ч������������
echo.
goto cl11

:n11
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul||(echo.&echo �Žӷ����Ѿ�����!����������������˵�&pause>nul&goto s1)
vnetlib%vmbit%.exe -- stop bridge
vnetlib%vmbit%.exe -- uninstall bridge
echo.
echo         �����Žӷ���ɹ�!��������Ч!����������������˵�
echo.
pause >nul
goto s1

:n12
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul&&(echo.&net start VMnetBridge >nul &&echo �Žӷ����Ѿ�����!����������������˵�&pause>nul&goto s1)
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >nul 2>nul || (vnetlib%vmbit%.exe -- install userif)
start /wait vnetlib%vmbit%.exe -- install adapter
start /wait vnetlib%vmbit%.exe -- install bridge
start /wait vnetlib%vmbit%.exe -- start bridge
echo.
echo         �����Žӷ���ɹ�!����������������˵�
echo.
pause >nul
goto s1

:n2
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1������nat����
echo.
echo         2������nat����Ĭ�ϰ�װ��������8��
echo.
echo         3������VMnet8 DHCP���ܣ�Ĭ�Ͽ�����
echo.
echo         4������VMnet8 DHCP����
echo.
echo         5�������������˵�
echo.
echo  ע��:  �����������VMnet1��Vmnet8��������ֶ���������
echo         ��IP/����/DNS�����Դ˴�����/���ã�Ҳ����������
echo         ����༭���н���VMnet DHCP ���ܣ�������DHCP���á�
:cl12
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n21
if /i "%choice%"=="2" goto n22
if /i "%choice%"=="3" goto n23
if /i "%choice%"=="4" goto n24
if /i "%choice%"=="5" goto s1
echo.
echo         ѡ����Ч������������
echo.
goto cl12

:n21
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo nat�����Ѿ�����!����������������˵�&pause>nul&goto s1)
vnetlib.exe -- remove adapter vmnet8
vnetlib.exe -- stop nat & vnetlib.exe -- uninstall nat
reg delete "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8" /f >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetAdapter\Enum /v Count >nul 2>nul|find "0x0" >nul 2>nul && (vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         ����nat����ɹ�!��������Ч!����������������˵�
echo.
pause >nul
goto s1

:n22
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul&&(echo.&net start "VMware NAT Service" >nul &&echo nat�����Ѿ�����!����������������˵�&pause>nul&goto s1)
net start Dhcp >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetuserif >nul 2>nul || (vnetlib%vmbit%.exe -- install userif)
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetDHCP >nul 2>nul || (vnetlib.exe -- install dhcp)
vnetlib.exe -- install nat
vnetlib.exe -- add adapter vmnet8
vnetlib.exe -- add dhcp vmnet8
vnetlib.exe -- add nat vmnet8
vnetlib.exe -- set vnet vmnet8 addr 192.168.128.0
vnetlib.exe -- stop nat
vnetlib.exe -- stop dhcp
vnetlib.exe -- update dhcp vmnet8
vnetlib.exe -- start dhcp
vnetlib.exe -- update nat vmnet8
vnetlib.exe -- start nat
vnetlib.exe -- update adapter vmnet8
echo.
echo         ����nat����ɹ�!��������Ч!����������������˵�
echo.
pause >nul
goto s1

:n23
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo δ��װ��������VMnet8!���������nat�˵�&pause>nul&goto n2)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP|find "0x1" >nul &&(echo.&echo ��������VMnet8 DHCP�Ѿ�����!���������nat�˵�&pause>nul&goto n2)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000001" /f >nul
vnetlib.exe -- stop nat
vnetlib.exe -- stop dhcp
vnetlib.exe -- start dhcp
vnetlib.exe -- update nat vmnet8
vnetlib.exe -- start nat
vnetlib.exe -- update adapter vmnet8
echo.
echo         ������������VMnet8 DHCP�ɹ�!�����nat�˵�
echo.
pause >nul
goto n2

:n24
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo δ��װ��������VMnet8!���������nat�˵�&pause>nul&goto n2)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP|find "0x0" >nul &&(echo.&echo ��������VMnet8 DHCP�Ѿ�����!���������nat�˵�&pause>nul&goto n2)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000000" /f >nul
vnetlib.exe -- stop dhcp
FOR /L %%i IN (0,1,19) DO reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet%%i\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul&&(vnetlib.exe -- start dhcp)
echo.
echo         ������������VMnet8 DHCP�ɹ�!���������nat�˵�
echo.
pause >nul
goto n2

:n3
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1������host-only����
echo.
echo         2������host-only����Ĭ�ϰ�װ��������1��
echo.
echo         3������VMnet1 DHCP���ܣ�Ĭ�Ͽ�����
echo.
echo         4������VMnet1 DHCP����
echo.
echo         5�������������˵�
echo.
echo  ע��:  �����������VMnet1��Vmnet8��������ֶ���������
echo         ��IP/����/DNS�����Դ˴�����/���ã�Ҳ����������
echo         ����༭���н���VMnet DHCP ���ܣ�������DHCP���á�

:cl13
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n31
if /i "%choice%"=="2" goto n32
if /i "%choice%"=="3" goto n33
if /i "%choice%"=="4" goto n34
if /i "%choice%"=="5" goto s1
echo.
echo         ѡ����Ч������������
echo.
goto cl13

:n31
cd /d "%~dp0"
vnetlib%vmbit%.exe -- remove adapter vmnet1
reg delete "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" /f >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetAdapter\Enum /v Count >nul 2>nul|find "0x0" >nul 2>nul && (vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         ����host-only����ɹ�!��������Ч!����������������˵�
echo.
pause >nul
goto s1

:n32
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetuserif >nul 2>nul||(vnetlib%vmbit%.exe -- install userif)
net start dhcp >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetDHCP >nul 2>nul||(vnetlib.exe -- install dhcp)
vnetlib.exe -- add adapter vmnet1
vnetlib.exe -- add dhcp vmnet1
vnetlib.exe -- set vnet vmnet1 addr 10.10.10.0
vnetlib.exe -- stop dhcp
vnetlib.exe -- update dhcp vmnet1
vnetlib.exe -- start dhcp
vnetlib.exe -- update adapter vmnet1
echo.
echo         ����host-only����ɹ�!����������������˵�
echo.
pause >nul
goto s1

:n33
cd /d "%~dp0"
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" >nul 2>nul||(echo.&echo δ��װ��������VMnet1!���������host-only�˵�&pause>nul&goto n3)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul &&(echo.&echo ��������VMnet1 DHCP�Ѿ�����!���������host-only�˵�&pause>nul&goto n3)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000001" /f >nul
vnetlib.exe -- start dhcp
vnetlib.exe -- stop dhcp
vnetlib.exe -- update dhcp vmnet1
vnetlib.exe -- start dhcp
vnetlib.exe -- update adapter vmnet1
echo.
echo         ������������VMnet1 DHCP�ɹ�!���������host-only�˵�
echo.
pause >nul
goto n3

:n34
cd /d "%~dp0"
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" >nul 2>nul||(echo.&echo δ��װ��������VMnet1!���������host-only�˵�&pause>nul&goto n3)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP >nul 2>nul|find "0x0" >nul 2>nul &&(echo.&echo ��������VMnet1 DHCP�Ѿ�����!���������host-only�˵�&pause>nul&goto n3)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000000" /f >nul
vnetlib.exe -- stop dhcp
FOR /L %%i IN (0,1,19) DO reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet%%i\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul&&(vnetlib.exe -- start dhcp)
echo.
echo         ������������VMnet1 DHCP�ɹ�!���������host-only�˵�
echo.
pause >nul
goto n3

:n4
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetdhcp >nul 2>nul&&(vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         ����VMnetDHCP����ɹ�!��������Ч!����������������˵�
echo         �˴�����ȫ����������DHCP �����뵥������VMnet1��VMnet8�����Ӧ�˵�
echo.
pause >nul
goto s1

:n5
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetdhcp >nul 2>nul||(vnetlib.exe -- install dhcp & vnetlib.exe -- start dhcp)
echo.
echo         ����VMnetDHCP����ɹ�!����������������˵�
echo         �˴�����ȫ����������DHCP �����뵥������VMnet1��VMnet8�����Ӧ�˵�
echo.
pause >nul
goto s1

:n6
cd /d "%~dp0"
vnetlib.exe -- uninstall adapter
echo.
echo         ����ȫ���������ɹ�!��������Ч!����������������˵�
echo.
pause >nul
goto s1

:s2
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1������USB����
echo.
echo         2������USB����
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl2
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s21
if /i "%choice%"=="2" goto s22
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl2
:s21
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul||(echo.&echo USB�����Ѿ�����!������������˵�&pause>nul&goto menu)
net stop VMUSBArbService
sc delete VMUSBArbService >nul 2>nul
vnetlib%vmbit%.exe -- stop usb
vnetlib%vmbit%.exe -- uninstall usb
vnetlib%vmbit%.exe -- stop hcmon
vnetlib%vmbit%.exe -- uninstall hcmon
rmdir /s /q "%CommonProgramFiles%\VMware\USB" >nul 2>nul
if /i %PROCESSOR_IDENTIFIER:~0,3% neq x86 rmdir /s /q "%CommonProgramFiles(x86)%\VMware" >nul 2>nul
echo.
echo         ����USB����ɹ�!��������Ч!������������˵�
echo.
pause >nul
goto menu

:s22
cd /d "%~dp0"
pushd %~dp0
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul&&(echo.&net start VMUSBArbService >nul&&echo USB�����Ѿ�����!������������˵�&pause>nul&goto menu)
set CommonPath86=%CommonProgramFiles(x86)%\VMware\USB
set CommonPath=%CommonProgramFiles%\VMware\Drivers
mkdir "%CommonPath86%"
xcopy .\USB\* "%CommonPath86%\" /E /Y >nul
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\VMware, Inc.\VMware USB" /v InstallPath /t REG_SZ /d "%CommonPath86%" /f >nul
cd /d "%CommonPath86%"
vnetlib%vmbit%.exe -- install hcmon
if not exist %WinDir%\system32\drivers\hcmon.sys copy /y "%CommonPath%\hcmon\win7\hcmon.sys" "%WinDir%\system32\drivers\"
ver|find "6.1">nul && (
rename .\vmusb.inf_win7 vmusb.inf >nul
rename .\vmusb.cat_win7 vmusb.cat >nul
rename .\vmusb.sys_win7 vmusb.sys >nul
rename .\vmusbver64.dll vmusbver.dll >nul
copy /y  .\vmusb.inf .\DriverCache\ >nul
copy /y  .\vmusb.cat .\DriverCache\ >nul
copy /y  .\vmusb.sys .\DriverCache\ >nul
copy /y  .\vmusbver.dll .\DriverCache\ >nul
del .\vmusb.inf_win8
del .\vmusb.cat_win8
del .\vmusb.sys_win8
del .\vmusbver64_win8.dll >nul
)
ver|find "6.1">nul || (
rename .\vmusb.inf_win8 vmusb.inf >nul
rename .\vmusb.cat_win8 vmusb.cat >nul
rename .\vmusb.sys_win8 vmusb.sys >nul
rename .\vmusbver64_win8.dll vmusbver.dll >nul
copy /y  .\vmusb.inf .\DriverCache\ >nul
copy /y  .\vmusb.cat .\DriverCache\ >nul
copy /y  .\vmusb.sys .\DriverCache\ >nul
copy /y  .\vmusbver.dll .\DriverCache\ >nul
del .\vmusb.inf_win7 >nul
del .\vmusb.cat_win7 >nul
del .\vmusb.sys_win7 >nul
del .\vmusbver64.dll >nul
)
vnetlib%vmbit%.exe -- install usb
sc create VMUSBArbService binpath= "\"%CommonPath86%\usbarbitrator%vmbit%.exe\"" start= auto depend= winmgmt displayname= "VMware USB Arbitration Service" >nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\VMUSBArbService" /v WOW64 /t REG_DWORD /d "0x00000001" /f
popd
net start VMUSBArbService
echo.
echo         ����USB����ɹ�!������������˵�
echo.
pause >nul
goto menu

:s3
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1�����á�����ӳ�书�ܡ�
echo.
echo         2�����á�����ӳ�书�ܡ�
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl3
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s31
if /i "%choice%"=="2" goto s32
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl3

:s31
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vstor2-mntapi20-shared" >nul 2>nul||(echo.&echo ����ӳ�书���Ѿ�����!������������˵�&pause>nul&goto menu)
net stop vstor2-mntapi20-shared >nul
sc delete vstor2-mntapi20-shared >nul
echo.
echo         ���ô���ӳ�书�ܳɹ�!��������ر����˵�
echo.
pause >nul
goto s3

:s32
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vstor2-mntapi20-shared" >nul 2>nul&&(echo.&net start "vstor2-mntapi20-shared" >nul &&echo ����ӳ�书���Ѿ�����!������������˵�&pause>nul&goto menu)

if not exist "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys" copy /y .\vstor2*.sys "%WinDir%\SysWOW64\drivers\"
sc create vstor2-mntapi20-shared type= kernel start= auto binpath= "SysWOW64\drivers\vstor2-mntapi20-shared.sys" displayname= "Vstor2 MntApi 2.0 Driver (shared)"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\vstor2-mntapi20-shared" /v WOW64 /t REG_DWORD /d "0x00000001" /f
net start vstor2-mntapi20-shared >nul

echo.
echo         ���ô���ӳ�书�ܳɹ�!��������ر����˵�
echo.
pause >nul
goto s3

:s4
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   ��ʾ:����ڳ�����ѡ������Ҫ����/���������ӡ��
echo.        ���ܣ������ڴ˹��ܲ˵������������ӡ������
echo.
echo.
echo         1�����������ӡ������
echo.
echo         2�����������ӡ������
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl4
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s41
if /i "%choice%"=="2" goto s42
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl4
:s41
cd /d "%~dp0"
echo.
echo         ���ڽ��������ӡ������...
echo.
start /wait vnetlib%vmbit%.exe -- stop parport
start /wait vnetlib%vmbit%.exe -- uninstall parport
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint" /f >nul 2>nul
echo.
echo         ���������ӡ������ɹ�!��������ر����˵�
echo.
pause >nul
goto s4
:s42
cd /d "%~dp0"
echo.
echo         ���ڰ�װ�����ӡ������...
echo.
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMparport >nul 2>nul && (echo.&net start VMparport >nul &&echo ��ӡ�����������Ѿ�����!&pause>nul&goto MENU)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint" /v Lang /t REG_SZ /d "enu" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint\Client"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint\Client" /v DefPrintState /t REG_DWORD /d "0x00000001" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint\Client" /v DefaultState /t REG_DWORD /d "0x00000001" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint\Client" /v PropertyRequestTimeout /t REG_DWORD /d "0x00000078" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint\Client" /v WatchPrinters /t REG_DWORD /d "0x00000001" /f
mkdir "%CommonProgramFiles(x86)%\ThinPrint"
xcopy .\ThinPrint\* "%CommonProgramFiles(x86)%\ThinPrint\" /E /Y >nul
start /wait vnetlib%vmbit%.exe -- install parport
start /wait vnetlib%vmbit%.exe -- start parport
echo.
echo         ��ӡ��֧�ְ�װ�ɹ�!��������ر����˵�
echo.
pause >nul
goto s4

:s5
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   ��ʾ:��װ�˷������ͨ���ͻ���Զ�����ӵ���������
echo.        ����Զ�̴����͹���������ϵ�������Ȳ���,�Լ�
echo.        �鿴Զ�̷�������CPU���ڴ桢Ӳ����Դ��״̬��.
echo.
echo.   ע��:��Ҫ���ڴ˲˵����÷�������ڳ�����ѡ��������/
echo.        ��������������Զ�̷��ʹ��ܣ������н��ù���     
echo.        ֻ�ǽ��÷��񣬵���ط��񻹰�װ��ϵͳ�С�����
echo.        �˴�����֮���������ʾ�����ã���ʵ���ǽ��õġ�
echo.
echo         1�����ù����������Զ�̷��ʷ���(Hostd����)
echo.
echo         2�����ù����������Զ�̷��ʷ���(Hostd����)
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl5
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s51
if /i "%choice%"=="2" goto s52
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl5
:s51
cd /d "%~dp0"
cls
echo         ���ڽ��ù����������Զ�̷��ʷ���(Hostd����)
echo.
net stop VMwareHostd
sc delete VMwareHostd >nul 2>nul
rd /s /q "%AllUsersProfile%\Application Data\VMware\hostd" >nul 2>nul
rd /s /q "%AllUsersProfile%\Application Data\VMware\SSL" >nul 2>nul
set profilepath=%AllUsersProfile%
start /wait str.exe "%profilepath%\VMware\hostd\config.xml" 0 0 /R /asc:"%cd%" /asc:"VMwareDir" /A >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\datastores.xml" 0 0 /R /asc:"%cd%" /asc:"VMwareDir" /A >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\stats\hostAgentStats.xml" 0 0 /R /asc:"%profilepath%\VMware" /asc:"hostdDir" /A >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\config.xml" 0 0 /R /asc:"%profilepath%\VMware" /asc:"hostdDir" /A >nul 2>nul
vnetlib.exe -- install dhcp
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetAdapter\Enum /v Count|find "0x0" >nul || (vnetlib.exe -- stop dhcp)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul && (vnetlib.exe -- start dhcp)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul && (vnetlib.exe -- start dhcp)
net start "VMware NAT Service" >nul 2>nul
echo.
cls
echo         ���ù����������Զ�̷��ʷ���(Hostd����)�ɹ�!������������˵�
echo.
pause >nul
goto menu

:s52
cd /d "%~dp0"
cls
echo.
echo         �������ù����������Զ�̷��ʷ���(Hostd����)
echo.

reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul || (echo.&echo ���Ȱ�װUSB����!������������˵�&pause>nul&goto menu)
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMwareHostd >nul 2>nul && (echo.&net start VMwareHostd >nul &&echo WEB���ʷ����Ѿ�����!&pause>nul&goto MENU)
net start LanmanWorkstation >nul 2>nul
net start VMAuthdService >nul 2>nul
net start VMUSBArbService >nul 2>nul
set profilepath=%AllUsersProfile%
md "%profilepath%\VMware\hostd" >nul 2>nul
md "%profilepath%\VMware\SSL" >nul 2>nul
xcopy Web\* "%profilepath%\VMware\hostd" /E /Y >nul 2>nul
copy /y SSL\hostd.ssl.config "%profilepath%\VMware\SSL\" >nul 2>nul
if not exist "%profilepath%\VMware\SSL\rui.key" openssl.exe req -x509 -days 365 -newkey rsa:2048 -keyout "%profilepath%\VMware\SSL\rui.key" -out "%profilepath%\VMware\SSL\rui.crt" -config "%profilepath%\VMware\SSL\hostd.ssl.config"
del /f /q *tmp* >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\config.xml" 0 0 /R /asc:"VMwareDir" /asc:"%cd%" /A >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\datastores.xml" 0 0 /R /asc:"VMwareDir" /asc:"%cd%" /A >nul 2>nul
start /wait str.exe "%profilepath%\VMware\hostd\config.xml" 0 0 /R /asc:"hostdDir" /asc:"%profilepath%\VMware" /A >nul 2>nul

sc create VMwareHostd binpath= "%cd%\vmware-hostd.exe -u \"%profilepath%\VMware\hostd\config.xml\"" start= auto depend= VMAuthdService/VMUSBArbService/lanmanworkstation  displayname= "VMware Workstation Server"

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\VMwareHostd" /v FailureCommand /t REG_SZ /d "\"%cd%\vm-support.vbs\"" /f

net start VMwareHostd
if %errorlevel% neq 0 echo ��������ʧ��,������������Ƿ�ɹ�����,��������ز˵�&pause >nul&goto s5
echo.
echo         �����������Զ�̷��ʷ���(Hostd����)��װ�ɹ�!������������˵�
echo.
pause >nul
goto menu

:s6
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   ��ʾ:��װ�˷���������������ʹ��CTRL+ALT+DEL��ϼ�
echo.
echo.
echo         1��������ǿ������̷���
echo.
echo         2��������ǿ������̷���
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl6
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s61
if /i "%choice%"=="2" goto s62
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl6
:s61

cd /d "%~dp0"
echo.
echo         ���ڽ�����ǿ������̷���
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vmkbd" >nul 2>nul||(net stop vmkbd >nul&sc delete vmkbd >nul)
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /f >nul 2>nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /t REG_MULTI_SZ /d "kbdclass\0" /f >nul 2>nul
echo.
echo         ��ǿ�����������ж�سɹ�,�������Ժ���Ч!������������˵�
echo.
pause >nul
goto menu

:s62
cd /d "%~dp0"
echo.
echo         ����������ǿ������̷���
echo.
copy /y .\vmkbd.sys %WinDir%\system32\drivers\ >nul 2>nul
sc create vmkbd binpath= "%windir%\system32\drivers\VMkbd.sys" Type= kernel  start= demand Group= "Keyboard Port" error= normal displayname= "VMware Input Filter and Injection Driver (vmkbd)"

for /f "tokens=*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v "UpperFilters"') do (set var=%%a)
set var=%var:UpperFilters=%
set var=%var:reg_multi_sz=%
for /f %%v in ('ver^|find /c " 5.1"') do (set wver=%%v)
if %wver%==1 (set var=%var:	=%) else (set var=%var:  =%)
if %wver%==1 (set var=%var:~,-4%)
for /f %%v in ('ver^|find /c "vmkbd"') do (set wver=%%v)
set EXISTS_FLAG=false
echo %var%|find "vmkbd">nul&&set EXISTS_FLAG=true
if %EXISTS_FLAG%==false (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /t REG_MULTI_SZ /d "%var%\0vmkbd" /f >nul 2>nul) else (echo �Ѿ���װ)
echo.
echo         ��ǿ�������������װ�ɹ�,�������Ժ���Ч!������������˵�
echo.
pause >nul
goto menu

:s7
cd /d "%~dp0"
pushd %~dp0
cls
if not exist ".\messages\zh_CN" (set lang=Ӣ��) else (set lang=����) >nul
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         ��ѡ��Ҫ���еĲ�����Ȼ�󰴻س�
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   ��ʾ:Ŀǰ VMware ����Ϊ: %lang%
echo.        ��ر� VMware �����,�ɹ������� VMware
echo.
echo         1������ΪӢ��
echo.
echo         2������Ϊ����
echo.
echo         3���������˵�
echo.
echo         4���˳�
:cl7
echo.
set /p choice=         ��ѡ��: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s71
if /i "%choice%"=="2" goto s72
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         ѡ����Ч������������
echo.
goto cl7
:s71
if not exist ".\messages\zh_CN" (echo.&echo �Ѿ���Ӣ����!��������ز˵�&pause>nul&goto s7)
cd messages >nul
rename zh_CN zh_NON >nul
popd
echo.
echo         VMware �Ѹ���ΪӢ��,������������˵�
echo.
pause >nul
goto menu
:s72
if exist ".\messages\zh_CN" (echo.&echo �Ѿ���������!��������ز˵�&pause>nul&goto s7)
cd messages >nul
rename zh_NON zh_CN >nul
popd
echo.
echo         VMware �Ѹ���Ϊ����,������������˵�
echo.
pause >nul
goto menu



:chkinfo
cd /d "%~dp0"
echo.
echo         ע��:�˹��������ռ�ϵͳ������VMware��װ��Ϣ
echo	          �����㰲װVMware������ɫ����޷���������
echo	          ������ɵ�install.log�����ң��Ա����ж�
echo		  �������������.
echo.
echo.
echo ��ʼ���,���Ժ�...
echo.
echo.
echo ���ע��� >> install.log
if /i %PROCESSOR_IDENTIFIER:~0,3% neq x86 echo 64λϵͳ >> install.log
IF "%PROCESSOR_ARCHITECTneq%" equ "x86"echo 32λϵͳ >> install.log

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName >> install.log
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CSDVersion >> install.log
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v BuildLab >> install.log
reg query "HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\CentralProcessor\0" /v ProcessorNameString >> install.log
reg query "HKLM\SOFTWARE\VMware, Inc." >> install.log 2>> install.log || reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc." >> install.log
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\vmware.exe" >>install.log
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Workstation" /v InstallPath >>install.log
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\VMware, Inc.\VMware Workstation" /v InstallPath64 >>install.log
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\VMware\Performance" /v Library >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >> install.log
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetDHCP >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >> install.log
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vstor2-mntapi20-shared" >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMAuthdService >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMparport >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMwareHostd >> install.log
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmkbd >> install.log

reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4B6C7001-C7D6-3710-913E-5BC23FCE91E6} >> install.log
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{86CE1746-9EFF-3C9C-8755-81EA8903AC34} >> install.log
reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{1b103cea-f037-4504-81de-956057b442c3} >> install.log
reg query HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{A749D8E6-B613-3BE3-8F5F-045C84EBA29B} >> install.log

echo.
echo.
set profilepath=%AllUsersProfile%
echo ����ļ����ļ��� >> install.log
if not exist "%profilepath%\VMware" echo "%profilepath%\VMware"������ >> install.log
if not exist "%profilepath%\VMware\VMware Workstation" echo "%profilepath%\VMware\VMware Workstation"������ >> install.log

if not exist "%WinDir%\System32\vnetinst.dll" echo "%WinDir%\System32\vnetinst.dll"������ >> install.log
if not exist "%profilepath%\VMware\VMware Workstation\config.ini" echo "%profilepath%\VMware\VMware Workstation\config.ini"������ >> install.log
if not exist "%AppData%\VMware\preferences.ini" echo "%AppData%\VMware\preferences.ini"������ >> install.log
if not exist "%WinDir%\SysWOW64\vsocklib.dll" echo "%WinDir%\SysWOW64\vsocklib.dll"������ >> install.log
if not exist "%WinDir%\system32\vsocklib.dll" echo "%WinDir%\system32\vsocklib.dll"������ >> install.log
if not exist "%WinDir%\System32\vnetlib%vmbit%.dll" echo "%WinDir%\System32\vnetlib%vmbit%.dll"������ >> install.log
if not exist "%AppData%\VMware\preferences.ini" echo "%AppData%\VMware\preferences.ini"������ >> install.log

if not exist "%CommonProgramFiles(x86)%\VMware\USB\vmware-USBArbitrator64.exe" echo "%CommonProgramFiles(x86)%\VMware\USB\vmware-USBArbitrator64.exe"������ >> install.log

if not exist "%WinDir%\system32\drivers\vmx86.sys" echo "%WinDir%\system32\drivers\vmx86.sys"������ >> install.log
if not exist "%WinDir%\system32\drivers\vmci.sys" echo "%WinDir%\system32\drivers\vmci.sys"������ >> install.log
if not exist "%WinDir%\system32\drivers\vsock.sys" echo "%WinDir%\system32\drivers\vsock.sys"������ >> install.log
if not exist "%WinDir%\system32\drivers\vmnetadapter.sys" echo "%WinDir%\system32\drivers\vmnetadapter.sys"������ >> install.log
if not exist "%WinDir%\system32\drivers\vmnetbridge.sys" echo "%WinDir%\system32\drivers\vmnetbridge.sys"������ >> install.log
if not exist "%WinDir%\system32\drivers\vmnetuserif.sys" echo "%WinDir%\system32\drivers\vmnetuserif.sys"������ >> install.log

if not exist "%WinDir%\system32\drivers\hcmon.sys" echo "%WinDir%\system32\drivers\hcmon.sys"������ >> install.log
if not exist "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys" echo "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys"������ >> install.log
if not exist "%WinDir%\SysWOW64\vmnetdhcp.exe" echo "%WinDir%\SysWOW64\vmnetdhcp.exe"������ >> install.log
if not exist "%WinDir%\SysWOW64\vmnat.exe" echo "%WinDir%\SysWOW64\vmnat.exe"������ >> install.log

echo.
echo. >> install.log
echo ����������״̬ >> install.log
echo ���vmx86���� >> install.log
net start vmx86 2>> install.log
echo ���vmci���� >> install.log
net start vmci 2>> install.log
echo ���vsock���� >> install.log
net start vsock 2>> install.log
echo ���VMnetAdapter���� >> install.log
net start VMnetAdapter 2>> install.log
echo ���VMnetBridge���� >> install.log
net start VMnetBridge 2>> install.log
echo ���VMnetuserif���� >> install.log
net start VMnetuserif 2>> install.log
echo ���VMAuthdService���� >> install.log
net start VMAuthdService 2>> install.log
echo ���VMnetDHCP���� >> install.log
net start VMnetDHCP 2>> install.log
echo ���"VMware NAT Service"���� >> install.log
net start "VMware NAT Service" 2>> install.log
echo ���hcmon���� >> install.log
net start hcmon 2>> install.log
echo ���VMUSBArbService���� >> install.log
net start VMUSBArbService 2>> install.log
echo ���VMwareHostd���� >> install.log
net start VMwareHostd 2>> install.log
echo ���"vstor2-mntapi20-shared"���� >> install.log
net start "vstor2-mntapi20-shared" 2>> install.log

net user %USERNAME% | find "�������Ա" >> install.log
net localgroup __vmware__ >> install.log
echo ������,��鿴���ɵ�install.log��־�ļ�.
pause >nul
echo.
cls
echo.
goto menu

:EX
exit