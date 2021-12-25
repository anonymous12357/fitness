cls
@ECHO OFF & CD /D %~DP0 & TITLE 安装 VMware Workstation 服务
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
echo          精简版相关服务安装 主菜单
echo         ===========================
echo.
echo         0、一键安装所有服务(USB、Hostd和虚拟打印机服务请另外安装)
echo         1、网络功能
echo         2、USB设备支持服务
echo         3、磁盘映射功能
echo         4、虚拟打印机服务
echo         5、共享虚拟机和远程访问服务(Hostd服务)
echo         6、安装增强虚拟键盘驱动
echo         7、更改中文系统环境下为英文界面
echo         8、安装结果检测并生成install.log日志(用于排错)
echo         e、退   出
echo.
echo         提示：0-6项不安装或全部禁用即为最小模式
:cl
echo.
set /p choice=         请选择要进行的操作，然后按回车: 
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
echo         选择无效，请重新输入
echo.
goto cl

:s0
echo.
set /p no=         请再次确认是否安装全部服务 Y(开始安装)或 N(退出安装)：
echo.
if /I "%no%"=="y" goto ks
if /I "%no%"=="n" exit
echo         输入错误，请重新输入...
goto s0cl
:ks
cls
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul&&(echo.&echo 请先卸载干净再安装!!!&pause>nul&goto MENU)
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >nul 2>nul&&(echo.&echo 请先卸载干净再安装!!!&pause>nul&goto MENU)
echo.
echo         正在安装，请稍后...
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
echo         一键安装所有服务成功！任意键返回主菜单
echo         你也可在主菜单中选择禁用不需要的服务
pause >nul
goto menu

:s1
cls
echo.
echo                网络服务菜单
echo         ==========================
echo.
echo         1、bridge(桥接)
echo.
echo         2、nat(网络共享)
echo.
echo         3、host-only(仅为主机)
echo.
echo         4、禁用VMnetDHCP服务(所有虚拟网卡)
echo.
echo         5、启用VMnetDHCP服务(所有虚拟网卡)
echo.
echo         6. 禁用全部网络功能
echo.
echo         7、返回主菜单
echo.
echo  温馨提示:
echo          不要在未重启系统时反复启用或停用某种网络服务；
:cl1
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n1
if /i "%choice%"=="2" goto n2
if /i "%choice%"=="3" goto n3
if /i "%choice%"=="4" goto n4
if /i "%choice%"=="5" goto n5
if /i "%choice%"=="6" goto n6
if /i "%choice%"=="7" goto menu
echo.
echo         选择无效，请重新输入
echo.
goto cl1

:n1
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1、禁用桥接服务
echo.
echo         2、启用桥接服务
echo.
echo         3、返回网络服务菜单
echo.
echo.
:cl11
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n11
if /i "%choice%"=="2" goto n12
if /i "%choice%"=="3" goto s1
echo.
echo         选择无效，请重新输入
echo.
goto cl11

:n11
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul||(echo.&echo 桥接服务已经禁用!任意键返回网络服务菜单&pause>nul&goto s1)
vnetlib%vmbit%.exe -- stop bridge
vnetlib%vmbit%.exe -- uninstall bridge
echo.
echo         禁用桥接服务成功!重启后生效!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:n12
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetBridge >nul 2>nul&&(echo.&net start VMnetBridge >nul &&echo 桥接服务已经启用!任意键返回网络服务菜单&pause>nul&goto s1)
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetuserif >nul 2>nul || (vnetlib%vmbit%.exe -- install userif)
start /wait vnetlib%vmbit%.exe -- install adapter
start /wait vnetlib%vmbit%.exe -- install bridge
start /wait vnetlib%vmbit%.exe -- start bridge
echo.
echo         启用桥接服务成功!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:n2
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1、禁用nat服务
echo.
echo         2、启用nat服务（默认安装虚拟网卡8）
echo.
echo         3、启用VMnet8 DHCP功能（默认开启）
echo.
echo         4、禁用VMnet8 DHCP功能
echo.
echo         5、返回网络服务菜单
echo.
echo  注意:  针对虚拟网卡VMnet1和Vmnet8，如果想手动设置虚拟
echo         机IP/网关/DNS，可以此处启用/禁用，也可以在虚拟
echo         网络编辑器中禁用VMnet DHCP 功能，并进行DHCP设置。
:cl12
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n21
if /i "%choice%"=="2" goto n22
if /i "%choice%"=="3" goto n23
if /i "%choice%"=="4" goto n24
if /i "%choice%"=="5" goto s1
echo.
echo         选择无效，请重新输入
echo.
goto cl12

:n21
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo nat服务已经禁用!任意键返回网络服务菜单&pause>nul&goto s1)
vnetlib.exe -- remove adapter vmnet8
vnetlib.exe -- stop nat & vnetlib.exe -- uninstall nat
reg delete "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8" /f >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetAdapter\Enum /v Count >nul 2>nul|find "0x0" >nul 2>nul && (vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         禁用nat服务成功!重启后生效!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:n22
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul&&(echo.&net start "VMware NAT Service" >nul &&echo nat服务已经启用!任意键返回网络服务菜单&pause>nul&goto s1)
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
echo         启用nat服务成功!重启后生效!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:n23
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo 未安装虚拟网卡VMnet8!任意键返回nat菜单&pause>nul&goto n2)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP|find "0x1" >nul &&(echo.&echo 虚拟网卡VMnet8 DHCP已经启用!任意键返回nat菜单&pause>nul&goto n2)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000001" /f >nul
vnetlib.exe -- stop nat
vnetlib.exe -- stop dhcp
vnetlib.exe -- start dhcp
vnetlib.exe -- update nat vmnet8
vnetlib.exe -- start nat
vnetlib.exe -- update adapter vmnet8
echo.
echo         启用虚拟网卡VMnet8 DHCP成功!任意键nat菜单
echo.
pause >nul
goto n2

:n24
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\VMware NAT Service" >nul 2>nul||(echo.&echo 未安装虚拟网卡VMnet8!任意键返回nat菜单&pause>nul&goto n2)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP|find "0x0" >nul &&(echo.&echo 虚拟网卡VMnet8 DHCP已经禁用!任意键返回nat菜单&pause>nul&goto n2)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet8\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000000" /f >nul
vnetlib.exe -- stop dhcp
FOR /L %%i IN (0,1,19) DO reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet%%i\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul&&(vnetlib.exe -- start dhcp)
echo.
echo         禁用虚拟网卡VMnet8 DHCP成功!任意键返回nat菜单
echo.
pause >nul
goto n2

:n3
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1、禁用host-only服务
echo.
echo         2、启用host-only服务（默认安装虚拟网卡1）
echo.
echo         3、启用VMnet1 DHCP功能（默认开启）
echo.
echo         4、禁用VMnet1 DHCP功能
echo.
echo         5、返回网络服务菜单
echo.
echo  注意:  针对虚拟网卡VMnet1和Vmnet8，如果想手动设置虚拟
echo         机IP/网关/DNS，可以此处启用/禁用，也可以在虚拟
echo         网络编辑器中禁用VMnet DHCP 功能，并进行DHCP设置。

:cl13
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto n31
if /i "%choice%"=="2" goto n32
if /i "%choice%"=="3" goto n33
if /i "%choice%"=="4" goto n34
if /i "%choice%"=="5" goto s1
echo.
echo         选择无效，请重新输入
echo.
goto cl13

:n31
cd /d "%~dp0"
vnetlib%vmbit%.exe -- remove adapter vmnet1
reg delete "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" /f >nul 2>nul
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMnetAdapter\Enum /v Count >nul 2>nul|find "0x0" >nul 2>nul && (vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         禁用host-only服务成功!重启后生效!任意键返回网络服务菜单
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
echo         启用host-only服务成功!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:n33
cd /d "%~dp0"
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" >nul 2>nul||(echo.&echo 未安装虚拟网卡VMnet1!任意键返回host-only菜单&pause>nul&goto n3)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul &&(echo.&echo 虚拟网卡VMnet1 DHCP已经启用!任意键返回host-only菜单&pause>nul&goto n3)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000001" /f >nul
vnetlib.exe -- start dhcp
vnetlib.exe -- stop dhcp
vnetlib.exe -- update dhcp vmnet1
vnetlib.exe -- start dhcp
vnetlib.exe -- update adapter vmnet1
echo.
echo         启用虚拟网卡VMnet1 DHCP成功!任意键返回host-only菜单
echo.
pause >nul
goto n3

:n34
cd /d "%~dp0"
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1" >nul 2>nul||(echo.&echo 未安装虚拟网卡VMnet1!任意键返回host-only菜单&pause>nul&goto n3)
reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP >nul 2>nul|find "0x0" >nul 2>nul &&(echo.&echo 虚拟网卡VMnet1 DHCP已经禁用!任意键返回host-only菜单&pause>nul&goto n3)
reg add "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet1\DHCP" /v UseDHCP /t REG_DWORD /d "0x00000000" /f >nul
vnetlib.exe -- stop dhcp
FOR /L %%i IN (0,1,19) DO reg query "HKLM\SOFTWARE\Wow6432Node\VMware, Inc.\VMnetLib\VMnetConfig\vmnet%%i\DHCP" /v UseDHCP >nul 2>nul|find "0x1" >nul 2>nul&&(vnetlib.exe -- start dhcp)
echo.
echo         禁用虚拟网卡VMnet1 DHCP成功!任意键返回host-only菜单
echo.
pause >nul
goto n3

:n4
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetdhcp >nul 2>nul&&(vnetlib.exe -- stop dhcp & vnetlib.exe -- uninstall dhcp)
echo.
echo         禁用VMnetDHCP服务成功!重启后生效!任意键返回网络服务菜单
echo         此处禁用全部虚拟网卡DHCP 服务，想单独设置VMnet1和VMnet8请进相应菜单
echo.
pause >nul
goto s1

:n5
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\vmnetdhcp >nul 2>nul||(vnetlib.exe -- install dhcp & vnetlib.exe -- start dhcp)
echo.
echo         启用VMnetDHCP服务成功!任意键返回网络服务菜单
echo         此处禁用全部虚拟网卡DHCP 服务，想单独设置VMnet1和VMnet8请进相应菜单
echo.
pause >nul
goto s1

:n6
cd /d "%~dp0"
vnetlib.exe -- uninstall adapter
echo.
echo         禁用全部网络服务成功!重启后生效!任意键返回网络服务菜单
echo.
pause >nul
goto s1

:s2
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1、禁用USB服务
echo.
echo         2、启动USB服务
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl2
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s21
if /i "%choice%"=="2" goto s22
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl2
:s21
cd /d "%~dp0"
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul||(echo.&echo USB服务已经禁用!任意键返回主菜单&pause>nul&goto menu)
net stop VMUSBArbService
sc delete VMUSBArbService >nul 2>nul
vnetlib%vmbit%.exe -- stop usb
vnetlib%vmbit%.exe -- uninstall usb
vnetlib%vmbit%.exe -- stop hcmon
vnetlib%vmbit%.exe -- uninstall hcmon
rmdir /s /q "%CommonProgramFiles%\VMware\USB" >nul 2>nul
if /i %PROCESSOR_IDENTIFIER:~0,3% neq x86 rmdir /s /q "%CommonProgramFiles(x86)%\VMware" >nul 2>nul
echo.
echo         禁用USB服务成功!重启后生效!任意键返回主菜单
echo.
pause >nul
goto menu

:s22
cd /d "%~dp0"
pushd %~dp0
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul&&(echo.&net start VMUSBArbService >nul&&echo USB服务已经启动!任意键返回主菜单&pause>nul&goto menu)
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
echo         启动USB服务成功!任意键返回主菜单
echo.
pause >nul
goto menu

:s3
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo         1、禁用“磁盘映射功能”
echo.
echo         2、启用“磁盘映射功能”
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl3
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s31
if /i "%choice%"=="2" goto s32
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl3

:s31
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vstor2-mntapi20-shared" >nul 2>nul||(echo.&echo 磁盘映射功能已经禁用!任意键返回主菜单&pause>nul&goto menu)
net stop vstor2-mntapi20-shared >nul
sc delete vstor2-mntapi20-shared >nul
echo.
echo         禁用磁盘映射功能成功!任意键返回本级菜单
echo.
pause >nul
goto s3

:s32
cd /d "%~dp0"
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vstor2-mntapi20-shared" >nul 2>nul&&(echo.&net start "vstor2-mntapi20-shared" >nul &&echo 磁盘映射功能已经启用!任意键返回主菜单&pause>nul&goto menu)

if not exist "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys" copy /y .\vstor2*.sys "%WinDir%\SysWOW64\drivers\"
sc create vstor2-mntapi20-shared type= kernel start= auto binpath= "SysWOW64\drivers\vstor2-mntapi20-shared.sys" displayname= "Vstor2 MntApi 2.0 Driver (shared)"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\vstor2-mntapi20-shared" /v WOW64 /t REG_DWORD /d "0x00000001" /f
net start vstor2-mntapi20-shared >nul

echo.
echo         启用磁盘映射功能成功!任意键返回本级菜单
echo.
pause >nul
goto s3

:s4
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   提示:如果在程序首选项中需要启用/禁用虚拟打印机
echo.        功能，需先在此功能菜单中启用虚拟打印机服务。
echo.
echo.
echo         1、禁用虚拟打印机服务
echo.
echo         2、启用虚拟打印机服务
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl4
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s41
if /i "%choice%"=="2" goto s42
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl4
:s41
cd /d "%~dp0"
echo.
echo         正在禁用虚拟打印机服务...
echo.
start /wait vnetlib%vmbit%.exe -- stop parport
start /wait vnetlib%vmbit%.exe -- uninstall parport
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\ThinPrint" /f >nul 2>nul
echo.
echo         禁用虚拟打印机服务成功!任意键返回本级菜单
echo.
pause >nul
goto s4
:s42
cd /d "%~dp0"
echo.
echo         正在安装虚拟打印机服务...
echo.
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMparport >nul 2>nul && (echo.&net start VMparport >nul &&echo 打印机串口驱动已经启用!&pause>nul&goto MENU)
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
echo         打印机支持安装成功!任意键返回本级菜单
echo.
pause >nul
goto s4

:s5
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   提示:安装此服务可以通过客户端远程连接到服务器端
echo.        进行远程创建和管理服务器上的虚拟机等操作,以及
echo.        查看远程服务器的CPU、内存、硬盘资源的状态等.
echo.
echo.   注意:需要先在此菜单启用服务才能在程序首选项中启用/
echo.        禁用虚拟机共享和远程访问功能，程序中禁用功能     
echo.        只是禁用服务，但相关服务还安装在系统中。而且
echo.        此处禁用之后程序中显示已启用，但实际是禁用的。
echo.
echo         1、禁用共享虚拟机和远程访问服务(Hostd服务)
echo.
echo         2、启用共享虚拟机和远程访问服务(Hostd服务)
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl5
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s51
if /i "%choice%"=="2" goto s52
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl5
:s51
cd /d "%~dp0"
cls
echo         正在禁用共享虚拟机和远程访问服务(Hostd服务)
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
echo         禁用共享虚拟机和远程访问服务(Hostd服务)成功!任意键返回主菜单
echo.
pause >nul
goto menu

:s52
cd /d "%~dp0"
cls
echo.
echo         正在启用共享虚拟机和远程访问服务(Hostd服务)
echo.

reg query HKLM\SYSTEM\CurrentControlSet\Services\VMUSBArbService >nul 2>nul || (echo.&echo 请先安装USB服务!任意键返回主菜单&pause>nul&goto menu)
reg query HKLM\SYSTEM\CurrentControlSet\Services\VMwareHostd >nul 2>nul && (echo.&net start VMwareHostd >nul &&echo WEB访问服务已经启用!&pause>nul&goto MENU)
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
if %errorlevel% neq 0 echo 服务启动失败,请检查关联服务是否成功启动,任意键返回菜单&pause >nul&goto s5
echo.
echo         共享虚拟机和远程访问服务(Hostd服务)安装成功!任意键返回主菜单
echo.
pause >nul
goto menu

:s6
cls
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   提示:安装此服务可以在虚拟机里使用CTRL+ALT+DEL组合键
echo.
echo.
echo         1、禁用增强虚拟键盘服务
echo.
echo         2、启用增强虚拟键盘服务
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl6
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s61
if /i "%choice%"=="2" goto s62
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl6
:s61

cd /d "%~dp0"
echo.
echo         正在禁用增强虚拟键盘服务
reg query "HKLM\SYSTEM\CurrentControlSet\Services\vmkbd" >nul 2>nul||(net stop vmkbd >nul&sc delete vmkbd >nul)
reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /f >nul 2>nul
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /t REG_MULTI_SZ /d "kbdclass\0" /f >nul 2>nul
echo.
echo         增强虚拟键盘驱动卸载成功,重启电脑后有效!任意键返回主菜单
echo.
pause >nul
goto menu

:s62
cd /d "%~dp0"
echo.
echo         正在启用增强虚拟键盘服务
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
if %EXISTS_FLAG%==false (reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\{4D36E96B-E325-11CE-BFC1-08002BE10318}" /v UpperFilters /t REG_MULTI_SZ /d "%var%\0vmkbd" /f >nul 2>nul) else (echo 已经安装)
echo.
echo         增强虚拟键盘驱动安装成功,重启电脑后有效!任意键返回主菜单
echo.
pause >nul
goto menu

:s7
cd /d "%~dp0"
pushd %~dp0
cls
if not exist ".\messages\zh_CN" (set lang=英文) else (set lang=中文) >nul
echo.
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo         请选择要进行的操作，然后按回车
echo         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo.
echo.   提示:目前 VMware 界面为: %lang%
echo.        请关闭 VMware 后操作,成功后重启 VMware
echo.
echo         1、更改为英文
echo.
echo         2、更改为中文
echo.
echo         3、返回主菜单
echo.
echo         4、退出
:cl7
echo.
set /p choice=         请选择: 
IF NOT "%choice%"=="" SET choice=%choice:~0,1%
if /i "%choice%"=="1" goto s71
if /i "%choice%"=="2" goto s72
if /i "%choice%"=="3" goto menu
if /i "%choice%"=="4" exit
echo.
echo         选择无效，请重新输入
echo.
goto cl7
:s71
if not exist ".\messages\zh_CN" (echo.&echo 已经是英文了!任意键返回菜单&pause>nul&goto s7)
cd messages >nul
rename zh_CN zh_NON >nul
popd
echo.
echo         VMware 已更改为英文,任意键返回主菜单
echo.
pause >nul
goto menu
:s72
if exist ".\messages\zh_CN" (echo.&echo 已经是中文了!任意键返回菜单&pause>nul&goto s7)
cd messages >nul
rename zh_NON zh_CN >nul
popd
echo.
echo         VMware 已更改为中文,任意键返回主菜单
echo.
pause >nul
goto menu



:chkinfo
cd /d "%~dp0"
echo.
echo         注意:此功能用于收集系统环境和VMware安装信息
echo	          若是你安装VMware精简绿色版后无法正常运行
echo	          则把生成的install.log发给我，以便我判断
echo		  哪里出现了问题.
echo.
echo.
echo 开始检测,请稍后...
echo.
echo.
echo 检测注册表 >> install.log
if /i %PROCESSOR_IDENTIFIER:~0,3% neq x86 echo 64位系统 >> install.log
IF "%PROCESSOR_ARCHITECTneq%" equ "x86"echo 32位系统 >> install.log

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
echo 检测文件和文件夹 >> install.log
if not exist "%profilepath%\VMware" echo "%profilepath%\VMware"不存在 >> install.log
if not exist "%profilepath%\VMware\VMware Workstation" echo "%profilepath%\VMware\VMware Workstation"不存在 >> install.log

if not exist "%WinDir%\System32\vnetinst.dll" echo "%WinDir%\System32\vnetinst.dll"不存在 >> install.log
if not exist "%profilepath%\VMware\VMware Workstation\config.ini" echo "%profilepath%\VMware\VMware Workstation\config.ini"不存在 >> install.log
if not exist "%AppData%\VMware\preferences.ini" echo "%AppData%\VMware\preferences.ini"不存在 >> install.log
if not exist "%WinDir%\SysWOW64\vsocklib.dll" echo "%WinDir%\SysWOW64\vsocklib.dll"不存在 >> install.log
if not exist "%WinDir%\system32\vsocklib.dll" echo "%WinDir%\system32\vsocklib.dll"不存在 >> install.log
if not exist "%WinDir%\System32\vnetlib%vmbit%.dll" echo "%WinDir%\System32\vnetlib%vmbit%.dll"不存在 >> install.log
if not exist "%AppData%\VMware\preferences.ini" echo "%AppData%\VMware\preferences.ini"不存在 >> install.log

if not exist "%CommonProgramFiles(x86)%\VMware\USB\vmware-USBArbitrator64.exe" echo "%CommonProgramFiles(x86)%\VMware\USB\vmware-USBArbitrator64.exe"不存在 >> install.log

if not exist "%WinDir%\system32\drivers\vmx86.sys" echo "%WinDir%\system32\drivers\vmx86.sys"不存在 >> install.log
if not exist "%WinDir%\system32\drivers\vmci.sys" echo "%WinDir%\system32\drivers\vmci.sys"不存在 >> install.log
if not exist "%WinDir%\system32\drivers\vsock.sys" echo "%WinDir%\system32\drivers\vsock.sys"不存在 >> install.log
if not exist "%WinDir%\system32\drivers\vmnetadapter.sys" echo "%WinDir%\system32\drivers\vmnetadapter.sys"不存在 >> install.log
if not exist "%WinDir%\system32\drivers\vmnetbridge.sys" echo "%WinDir%\system32\drivers\vmnetbridge.sys"不存在 >> install.log
if not exist "%WinDir%\system32\drivers\vmnetuserif.sys" echo "%WinDir%\system32\drivers\vmnetuserif.sys"不存在 >> install.log

if not exist "%WinDir%\system32\drivers\hcmon.sys" echo "%WinDir%\system32\drivers\hcmon.sys"不存在 >> install.log
if not exist "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys" echo "%WinDir%\SysWOW64\drivers\vstor2-mntapi20-shared.sys"不存在 >> install.log
if not exist "%WinDir%\SysWOW64\vmnetdhcp.exe" echo "%WinDir%\SysWOW64\vmnetdhcp.exe"不存在 >> install.log
if not exist "%WinDir%\SysWOW64\vmnat.exe" echo "%WinDir%\SysWOW64\vmnat.exe"不存在 >> install.log

echo.
echo. >> install.log
echo 检测服务运行状态 >> install.log
echo 检测vmx86服务 >> install.log
net start vmx86 2>> install.log
echo 检测vmci服务 >> install.log
net start vmci 2>> install.log
echo 检测vsock服务 >> install.log
net start vsock 2>> install.log
echo 检测VMnetAdapter服务 >> install.log
net start VMnetAdapter 2>> install.log
echo 检测VMnetBridge服务 >> install.log
net start VMnetBridge 2>> install.log
echo 检测VMnetuserif服务 >> install.log
net start VMnetuserif 2>> install.log
echo 检测VMAuthdService服务 >> install.log
net start VMAuthdService 2>> install.log
echo 检测VMnetDHCP服务 >> install.log
net start VMnetDHCP 2>> install.log
echo 检测"VMware NAT Service"服务 >> install.log
net start "VMware NAT Service" 2>> install.log
echo 检测hcmon服务 >> install.log
net start hcmon 2>> install.log
echo 检测VMUSBArbService服务 >> install.log
net start VMUSBArbService 2>> install.log
echo 检测VMwareHostd服务 >> install.log
net start VMwareHostd 2>> install.log
echo 检测"vstor2-mntapi20-shared"服务 >> install.log
net start "vstor2-mntapi20-shared" 2>> install.log

net user %USERNAME% | find "本地组成员" >> install.log
net localgroup __vmware__ >> install.log
echo 检测完毕,请查看生成的install.log日志文件.
pause >nul
echo.
cls
echo.
goto menu

:EX
exit