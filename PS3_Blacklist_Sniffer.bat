::------------------------------------------------------------------------------
:: NAME
::     PS3_Blacklist_Sniffer.bat - PS3 Blacklist Sniffer
::
:: DESCRIPTION
::     Track your blacklisted people new usernames and IPs.
::     Detect blacklisted people who are trying
::     to connect in or who are already in to your session.
::
:: REQUIREMENTS
::     Windows 10 or 11 (x86/x64)
::     Wireshark (with Npcap/Winpcap installed)
::     webMAN MOD ((PS3 Notification) not obligatory)
::
:: AUTHOR
::     IB_U_Z_Z_A_R_Dl
::
:: CREDITS
::     @Rosalyn - *giving me the force*
::     @NotYourDope - Helped me for generating the PS3 console notifications.
::     @NotYourDope - Helped me for English translations.
::     @Simi - Helped me for some English translations.
::     @Grub4K - Creator of the timer algorithm.
::     @Grub4K - Creator of the the ending newline detection algorithm.
::     @Grub4K - Helped me improving the hexadecimal algorithms.
::     @Grub4K - Helped me improving the updater algorithm.
::     @Grub4K - Quick analysis of the source code to improve it.
::     @Grub4K and @Sintrode
::     Helped me understand the Windows 7 (x86)
::     "find.exe" command bug with the 65001 codepage.
::     To avoid similar problems in the future and solve it,
::     I decided to remove the support for Windows 7, 8, 8.1
::     @Grub4K and @Sintrode
::     Helped me solve and understand a Batch bug with "FOR" loop variables.
::     @sintrode and https://www.dostips.com/forum/viewtopic.php?t=6560
::     ^^ "How to put inner quotes in outer quotes in "FOR" loop?"
::
::     A project created in the "server.bat" Discord: https://discord.gg/GSVrHag
::------------------------------------------------------------------------------
@echo off
cls
setlocal DisableDelayedExpansion
pushd "%~dp0"
for /f %%A in ('copy /z "%~nx0" nul') do (
    set "\R=%%A"
)
for /f %%A in ('forfiles /m "%~nx0" /c "cmd /c echo(0x08"') do (
    set "\B=%%A"
)
set @MSGBOX=(if not exist "lib\msgbox.vbs" call :MSGBOX_GENERATION)^& cscript //nologo "lib\msgbox.vbs"
set @MSGBOX_B=(if not exist "lib\msgbox.vbs" call :MSGBOX_GENERATION)^& start /b cscript //nologo "lib\msgbox.vbs"
set @TIMER_T1=for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "?_t1_!ip!=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"
set @TIMER_T2=for /f "tokens=1-4delims=:.," %%A in ("!time: =0!") do set /a "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100, tDiff=t2-?_t1_!ip!, tDiff+=((~(tDiff&(1<<31))>>31)+1)*8640000, ?_seconds_!ip!=tDiff/100"
set #MAP_ASCII_TO_HEX=#--2D#0030#1131#2232#3333#4434#5535#6636#7737#8838#9939#AA41#BB42#CC43#DD44#EE45#FF46#GG47#HH48#II49#JJ4A#KK4B#LL4C#MM4D#NN4E#OO4F#PP50#QQ51#RR52#SS53#TT54#UU55#VV56#WW57#XX58#YY59#ZZ5A#__5F#aa61#bb62#cc63#dd64#ee65#ff66#gg67#hh68#ii69#jj6A#kk6B#ll6C#mm6D#nn6E#oo6F#pp70#qq71#rr72#ss73#tt74#uu75#vv76#ww77#xx78#yy79#zz7A
set #MAP_HEX_TO_ASCII=#2D-#300#311#322#333#344#355#366#377#388#399#41A#42B#43C#44D#45E#46F#47G#48H#49I#4AJ#4BK#4CL#4DM#4EN#4FO#50P#51Q#52R#53S#54T#55U#56V#57W#58X#59Y#5AZ#5F_#61a#62b#63c#64d#65e#66f#67g#68h#69i#6Aj#6Bk#6Cl#6Dm#6En#6Fo#70p#71q#72r#73s#74t#75u#76v#77w#78x#79y#7Az
setlocal EnableDelayedExpansion
set @LOOKUP_PSN_LENGTH=`136`1160`
set @LOOKUP_IPLOOKUP_FIELDS=`status`message`continent`continentCode`country`countryCode`region`regionName`city`district`zip`lat`lon`timezone`offset`currency`isp`org`as`asname`reverse`mobile`proxy`hosting`query`proxy_2`type`
(set \N=^
%=leave unchanged=%
)
if defined ProgramFiles(x86) (
    set "PATH=!PATH!;lib\curl\x64"
) else (
    set "PATH=!PATH!;lib\curl\x86"
)
if defined VERSION (
    set OLD_VERSION=!VERSION!
)
if defined last_version (
    set OLD_LAST_VERSION=!last_version!
)
set VERSION=v2.2.4 - 30/05/2022
set TITLE=PS3 Blacklist Sniffer
set TITLE_VERSION=PS3 Blacklist Sniffer !VERSION:~0,6!
title !TITLE_VERSION!
for /f "tokens=4-7delims=[.] " %%A in ('ver') do (
    if /i "%%A"=="version" (
        set "WINDOWS_VERSION=%%B.%%C"
    ) else (
        set "WINDOWS_VERSION=%%A.%%B"
    )
)
if not "!WINDOWS_VERSION!"=="10.0" (
    %@MSGBOX% "Your Windows version is not compatible with PS3 Blacklist Sniffer.!\N!!\N!You need Windows 10/11 (x86/x64)." 69648 "!TITLE_VERSION!"
    exit /b 0
)
>nul chcp 65001
echo:
echo Searching for a new update ...
call :UPDATER || (
    echo ERROR: Failed updating. Try updating manually:
    echo https://github.com/Illegal-Services/PS3-Blacklist-Sniffer
    echo:
    <nul set /p=Press {ANY KEY} to continue ...
    >nul pause
)
>nul 2>&1 sc query npcap || (
    >nul 2>&1 sc query npf || (
        %@MSGBOX% "!TITLE! could not detect the 'Npcap' or 'WinpCap' driver installed on your system.!\N!!\N!Redirecting you to Npcap download page." 69648 "!TITLE_VERSION!"
        start "" "https://nmap.org/npcap/"
        exit /b 0
    )
)
for %%A in (
    ARP.EXE
    curl.exe
    notepad.exe
) do (
    >nul 2>&1 where "%%A" || (
        %@MSGBOX% "!TITLE! could not find '%%A' executable in your system PATH.!\N!!\N!Your system does not meet the minimum software requirements to use !TITLE!." 69648 "!TITLE_VERSION!"
        exit /b 0
    )
)
echo:
echo Applying your custom settings from 'Settings.ini' ...
:SETUP
set /a settings_number=0, clear_vars_timer_seconds_max=0
set "lookup_memory_blacklisted_found=`"
for %%A in (
    "@WINDOWS_TSHARK_STDERR"
    "@PS3_IP_ADDRESS"
    "@PS3_MAC_ADDRESS"
    "@PS3_NOTIFICATIONS_ABOVE_SOUND"
    "last_version"
    "generate_new_settings_file"
    "pid_notepad"
    "ps3_connected_notification"
) do (
    if defined %%~A (
        set %%~A=
    )
)
for %%A in (
    "WINDOWS_TSHARK_PATH"
    "WINDOWS_TSHARK_STDERR"
    "WINDOWS_BLACKLIST_PATH"
    "WINDOWS_RESULTS_LOGGING"
    "WINDOWS_RESULTS_LOGGING_PATH"
    "WINDOWS_NOTIFICATIONS"
    "WINDOWS_NOTIFICATIONS_TIMER"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER"
    "PS3_IP_AND_MAC_ADDRESS_AUTOMATIC"
    "PS3_IP_ADDRESS"
    "PS3_MAC_ADDRESS"
    "PS3_PROTECTION"
    "PS3_NOTIFICATIONS"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND"
    "PS3_NOTIFICATIONS_ABOVE"
    "PS3_NOTIFICATIONS_ABOVE_ICON"
    "PS3_NOTIFICATIONS_ABOVE_SOUND"
    "PS3_NOTIFICATIONS_ABOVE_TIMER"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER"
    "PS3_NOTIFICATIONS_BOTTOM"
    "PS3_NOTIFICATIONS_BOTTOM_SOUND"
    "PS3_NOTIFICATIONS_BOTTOM_TIMER"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER"
    "DETECTION_TYPE_DYNAMIC_IP_PRECISION"
) do (
    if defined %%~A (
        set %%~A=
    )
    if exist "Settings.ini" (
        set first_1=1
        for /f "tokens=1*delims==" %%B in ('findstr /bc:"%%~A=" "Settings.ini"') do (
            set /a settings_number+=1
            if defined first_1 (
                set first_1=
                if "%%~B"=="WINDOWS_TSHARK_PATH" (
                    set "%%~A=%%~C"
                    call :CREATE_WINDOWS_TSHARK_PATH || (
                        exit /b 0
                    )
                ) else if "%%~B"=="WINDOWS_TSHARK_STDERR" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                            if "%%~C"=="false" (
                                set "@%%~A=2^>nul "
                            )
                        )
                    )
                ) else if "%%~B"=="WINDOWS_BLACKLIST_PATH" (
                    set "%%~A=%%~C"
                    call :CREATE_WINDOWS_BLACKLIST_FILE
                ) else if "%%~B"=="WINDOWS_RESULTS_LOGGING" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="WINDOWS_RESULTS_LOGGING_PATH" (
                    set "%%~A=%%~C"
                    call :CREATE_WINDOWS_RESULTS_LOGGING_FILE
                ) else if "%%~B"=="WINDOWS_NOTIFICATIONS" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="WINDOWS_NOTIFICATIONS_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="PS3_IP_AND_MAC_ADDRESS_AUTOMATIC" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_IP_ADDRESS" (
                    set "x=%%~C"
                    call :CHECK_IP x && (
                        set "%%~A=%%~C"
                    )
                ) else if "%%~B"=="PS3_MAC_ADDRESS" (
                    set "x=%%~C"
                    call :CHECK_MAC x && (
                        set "%%~A=%%~C"
                    )
                ) else if "%%~B"=="PS3_PROTECTION" (
                    for %%D in (false Reload_Game Exit_Game Restart_PS3 Shutdown_PS3) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON" (
                    for /l %%D in (0,1,50) do (
                        if "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_ICON" (
                    for /l %%D in (0,1,50) do (
                        if "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_SOUND" (
                    for %%D in (false 0 1 2 3 4 5 6 7 8 9) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL" (
                    for %%D in (true false) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                ) else if "%%~B"=="PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER" (
                    set "x=%%~C"
                    call :CHECK_NUMBER x && (
                        set "%%~A=!x!"
                    )
                ) else if "%%~B"=="DETECTION_TYPE_DYNAMIC_IP_PRECISION" (
                    for %%D in (1 2 3) do (
                        if /i "%%~C"=="%%D" (
                            set "%%~A=%%~C"
                        )
                    )
                )
            )
        )
    ) else (
        if not defined generate_new_settings_file (
            set generate_new_settings_file=1
        )
        goto :JUMP_1
    )
)
if not "!settings_number!"=="28" (
    if not defined generate_new_settings_file (
        set generate_new_settings_file=1
    )
)
:JUMP_1
if defined settings_number (
    set settings_number=
)
for %%A in (
    "WINDOWS_TSHARK_STDERR=true"
    "WINDOWS_BLACKLIST_PATH=Blacklist.ini"
    "WINDOWS_RESULTS_LOGGING=true"
    "WINDOWS_RESULTS_LOGGING_PATH=Logs.txt"
    "WINDOWS_NOTIFICATIONS=true"
    "WINDOWS_NOTIFICATIONS_TIMER=0"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL=true"
    "WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER=120"
    "PS3_IP_AND_MAC_ADDRESS_AUTOMATIC=true"
    "PS3_PROTECTION=false"
    "PS3_NOTIFICATIONS=true"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=22"
    "PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=5"
    "PS3_NOTIFICATIONS_ABOVE=true"
    "PS3_NOTIFICATIONS_ABOVE_ICON=23"
    "PS3_NOTIFICATIONS_ABOVE_SOUND=3"
    "PS3_NOTIFICATIONS_ABOVE_TIMER=0"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=120"
    "PS3_NOTIFICATIONS_BOTTOM=true"
    "PS3_NOTIFICATIONS_BOTTOM_SOUND=8"
    "PS3_NOTIFICATIONS_BOTTOM_TIMER=0"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL=true"
    "PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER=3"
    "DETECTION_TYPE_DYNAMIC_IP_PRECISION=3"
) do (
    for /f "tokens=1*delims==" %%B in ("%%~A") do (
        if not defined %%~B (
            set "%%~B=%%~C"
            if not defined generate_new_settings_file (
                set generate_new_settings_file=1
            )
        )
    )
)
if %PS3_NOTIFICATIONS%==true (
    if %PS3_NOTIFICATIONS_ABOVE%==false (
        if %PS3_NOTIFICATIONS_BOTTOM%==false (
            set PS3_NOTIFICATIONS=false
            if not defined generate_new_settings_file (
                set generate_new_settings_file=1
            )
        )
    )
)
if defined generate_new_settings_file (
    echo:
    echo Correct reconstruction of 'Settings.ini' ...
    call :CREATE_SETTINGS_FILE
    goto :SETUP
)
for %%A in (
    WINDOWS_NOTIFICATIONS_TIMER
    WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER
    PS3_NOTIFICATIONS_ABOVE_TIMER
    PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER
    PS3_NOTIFICATIONS_BOTTOM_TIMER
    PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER
) do (
    if !%%A! gtr !clear_vars_timer_seconds_max! (
        set clear_vars_timer_seconds_max=!%%A!
    )
)
if not defined WINDOWS_TSHARK_PATH (
    call :CREATE_WINDOWS_TSHARK_PATH || (
        exit /b 0
    )
)
title Capture network interface selection - !TITLE_VERSION!
:CHOOSE_INTERFACE
cls
echo:
set cn=0
for /f "tokens=1*delims=(" %%A in ('"!WINDOWS_TSHARK_PATH!" -D') do (
    set /a cn+=1
    set "interface_!cn!=%%B"
    for %%C in (!cn!) do (
        set "interface_!cn!=!interface_%%C:~0,-1!"
    )
    <nul set /p="%%A(%%B"
    echo:
)
echo:
set CAPTURE_INTERFACE=
set /p "CAPTURE_INTERFACE=Select your desired capture network interface (1,1,!cn!): "
for /l %%A in (1,1,!cn!) do (
    if "%%A"=="!CAPTURE_INTERFACE!" (
        goto :JUMP_2
    )
)
goto :CHOOSE_INTERFACE
:JUMP_2
cls
title Cleaning temporary files - !TITLE_VERSION!
echo:
echo Cleaning incorrect, invalid or unnecessary temporary !TITLE! files ...
if exist "lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
    del /f /q "lib\tmp\_blacklisted_psn_hexadecimal.tmp"
)
<nul set /p="Checking temporary file 'blacklisted_psn_hexadecimal.tmp' ...!\R!"
if exist "!WINDOWS_BLACKLIST_PATH!" (
    if exist "lib\tmp\blacklisted_psn_hexadecimal.tmp" (
        for /f "usebackqdelims==" %%A in ("lib\tmp\blacklisted_psn_hexadecimal.tmp") do (
            >nul findstr /bc:"%%~A=" "!WINDOWS_BLACKLIST_PATH!" || (
                >"lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
                    <"lib\tmp\blacklisted_psn_hexadecimal.tmp" find /v "%%~A="
                ) || (
                    if not exist "lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
                        call :ERROR_FATAL WRITING_FAILURE "lib\tmp\_blacklisted_psn_hexadecimal.tmp"
                    )
                )
            )
        )
        if exist "lib\tmp\_blacklisted_psn_hexadecimal.tmp" (
            >nul move /y "lib\tmp\_blacklisted_psn_hexadecimal.tmp" "lib\tmp\blacklisted_psn_hexadecimal.tmp"
        )
    )
)
for %%A in ("lib\tmp\dynamic_iplookup_*.tmp") do (
    <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
    del /f /q "%%~A"
)
for %%A in ("lib\tmp\blacklisted_iplookup_*.tmp") do (
    <nul set /p="Checking temporary file '%%~nxA' ...                                        !\R!"
    if defined delete_file (
        set delete_file=
    )
    for /f "usebackqtokens=1*delims==" %%B in ("lib\tmp\%%~nxA") do (
        if "%%~B=%%~C"=="proxy_2=N/A" (
            set delete_file=1
        )
        if defined delete_file (
            if "%%~B=%%~C"=="type=N/A" (
                <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
                del /f /q "%%~A"
            )
        )
    )
)
if defined delete_file (
    set delete_file=
)
if exist "!WINDOWS_BLACKLIST_PATH!" (
    for %%A in ("lib\tmp\blacklisted_iplookup_*.tmp") do (
        <nul set /p="Checking temporary file '%%~nxA' ...                                        !\R!"
        set "x=%%~nA"
        >nul findstr /ec:"=!x:blacklisted_iplookup_=!" "!WINDOWS_BLACKLIST_PATH!" || (
            <nul set /p="Deleting temporary file '%%~nxA' ...                                        !\R!"
            del /f /q "%%~A"
        )
    )
)
cls
title Initializing addresses and establishing connection to your PS3 console - !TITLE_VERSION!
echo:
if !PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!==true (
    echo Initializing addresses and establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    set /a search_ps3_ip_address=1, first_2=1
    call :PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
    if defined PS3_IP_ADDRESS (
        call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS && (
            set search_ps3_ip_address=
            set first_2=
        )
    )
    for /f "tokens=1,2" %%A in ('ARP -a') do (
        if not "%%~B"=="" (
            set "x1=%%~A"
            call :CHECK_IP x1 && (
                set "local_ip_!x1!=1"
                set "x2=%%~B"
                set "x2=!x2:-=:!"
                if defined search_ps3_ip_address (
                    call :CHECK_MAC x2 && (
                        if defined first_2 (
                            set first_2=
                            echo PS3 console IP and MAC addresses not found.
                            echo Attempting the automatic detection of your PS3 console ...
                            echo:
                        )
                        echo Trying connection on local: "!x1!"
                        call :CHECK_WEBMAN_MOD_CONNECTION x1 x2 && (
                            set search_ps3_ip_address=
                            set "PS3_IP_ADDRESS=!x1!"
                            set "PS3_MAC_ADDRESS=!x2!"
                            call :CREATE_SETTINGS_FILE
                        )
                    )
                )
            )
        )
    )
    for %%A in (
        search_ps3_ip_address
        first_2
        x1
        x2
    ) do (
        set %%~A=
    )
) else if defined PS3_IP_ADDRESS (
    echo Establishing connection to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    call :CHECK_WEBMAN_MOD_CONNECTION PS3_IP_ADDRESS PS3_MAC_ADDRESS
)
title Computing ascii PSN usernames to hexadecimal in memory - !TITLE_VERSION!
:LOOP_BLACKLIST_FILE_EMPTY
cls
echo:
if defined ps3_connected_notification (
    echo Successfully connected to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
) else (
    echo Error: Unable to connect to your PS3 console: ^|IP:!PS3_IP_ADDRESS!^| ^|MAC:!PS3_MAC_ADDRESS!^| ...
    echo Make sure you have the following:
    echo - Your PS3 console must be turned on.
    echo - webMAN MOD is correctly configured on your PS3 console.
    echo - If you have a HEN jailbreaked console, make sure HEN is enabled.
    if not defined PS3_IP_ADDRESS (
        echo PS3 notifications disabled for this session.
    )
)
echo:
for %%A in (
    blacklisted_invalid_psn
    blacklisted_invalid_ip
) do (
    if defined %%A (
        set %%A=
    )
)
if exist "!WINDOWS_BLACKLIST_PATH!" (
    echo Computing ascii PSN usernames to hexadecimal in memory and
    echo checking "!WINDOWS_BLACKLIST_PATH!" PSN Usernames and IP addresses ...
    for /f "usebackqtokens=1,2delims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
        for %%C in (
            blacklisted_psn_padding
            blacklisted_ip_padding
            blacklisted_invalid_found
        ) do (
            if defined %%C (
                set %%C=
            )
        )
        if not "%%~A"=="" (
            set "blacklisted_psn=%%~A"
            set "blacklisted_ip=%%~B"
            set "blacklisted_psn_padding=!blacklisted_psn:~0,16!"
            if not "%%~B"=="" (
                set "blacklisted_ip_padding=!blacklisted_ip:~0,15!"
            )
            <nul set /p="Processing blacklisted entry [!blacklisted_psn_padding!=!blacklisted_ip_padding!] ...                               !\R!"
            call :ASCII_TO_HEXADECIMAL || (
                set /a blacklisted_invalid_psn=1, blacklisted_invalid_found=1
                <nul set /p="Blacklisted entry [!blacklisted_psn_padding!=!blacklisted_ip_padding!] does not contain a valid PSN username."
                echo:
            )
            if not "%%~B"=="" (
                call :CHECK_IP blacklisted_ip || (
                    set /a blacklisted_invalid_ip=1, blacklisted_invalid_found=1
                    <nul set /p="Blacklisted entry [!blacklisted_psn_padding!=!blacklisted_ip_padding!] does not contain a valid IP address."
                    echo:
                )
            )
        )
    )
    if not defined blacklisted_invalid_found (
        <nul set /p=".!\B!                                                                   "
    )
    for %%A in (
        blacklisted_psn
        blacklisted_psn_padding
        blacklisted_ip
        blacklisted_ip_padding
        blacklisted_invalid_found
    ) do (
        set %%A=
    )
) else (
    call :CREATE_WINDOWS_BLACKLIST_FILE
    goto :LOOP_BLACKLIST_FILE_EMPTY
)
echo:
if defined blacklisted_invalid_psn (
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo Unable to perform the PSN username search for this entrie^(s^) in your 'WINDOWS_BLACKLIST_PATH' setting.
    echo Please ensure the PSN username is correct, and check for the following errors:
    echo PSN usernames must consist of 3-16 characters, and only contain: [a-z] [A-Z] [0-9] [-] [_]
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo:
    set blacklisted_invalid_psn=
)
if defined blacklisted_invalid_ip (
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo Unable to perform the IP adress search for this entrie^(s^) in your 'WINDOWS_BLACKLIST_PATH' setting.
    echo Please ensure the IP address is correct, and check for the following errors:
    echo The IP address must be composed of 4 octets of a number from 0 to 255 each separated by a dot.
    <nul set /p="^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^"
    echo:
    echo:
    set blacklisted_invalid_ip=
)
:WAIT_FILE_SAVED_WINDOWS_BLACKLIST_PATH
>nul 2>&1 set blacklisted_psn_hexadecimal_ || (
    if defined pid_notepad (
        2>nul tasklist /nh /fo csv /fi "pid eq !pid_notepad!" | >nul find /i """notepad.exe""" || (
            set pid_notepad=
        )
    )
    if not defined pid_notepad (
        %@MSGBOX% "!TITLE! could not find any valid users in your 'WINDOWS_BLACKLIST_PATH' setting.!\N!!\N!Add your first entry to start scanning." 69648 "!TITLE_VERSION!"
        notepad.exe "!WINDOWS_BLACKLIST_PATH!" && (
            >nul timeout /t 1 /nobreak
        )
        for /f "tokens=2delims=," %%A in ('2^>nul tasklist /nh /fo csv /fi "imagename eq notepad.exe" ^| find /i """notepad.exe"""') do (
            set "pid_notepad=%%~A"
        )
    )
    if exist "!WINDOWS_BLACKLIST_PATH!" (
        for /f "usebackqdelims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
            if not "%%~A"=="" (
                goto :LOOP_BLACKLIST_FILE_EMPTY
            )
        )
    ) else (
        call :CREATE_WINDOWS_BLACKLIST_FILE
    )
    goto :WAIT_FILE_SAVED_WINDOWS_BLACKLIST_PATH
)
if defined PS3_IP_ADDRESS (
    set "@PS3_IP_ADDRESS=dst or src host !PS3_IP_ADDRESS! and "
    if "!VERSION:~1,5!" lss "!last_version:~1,5!" (
        >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/notify.ps3mapi?msg=!TITLE_VERSION: =+!:%%0D%%0AA+newer+version+is+detected+(v!last_version:~1,5!).&icon=21&snd=5"
    )
)
if defined PS3_MAC_ADDRESS (
    set "@PS3_MAC_ADDRESS=ether dst or src !PS3_MAC_ADDRESS! and "
)
set "CAPTURE_FILTER=!@PS3_IP_ADDRESS!!@PS3_MAC_ADDRESS!ip and udp and not broadcast and not multicast and not port 443 and not port 80 and not port 53 and not net 3.237.117.0/24 and not net 52.40.62.0/24 and not net 162.244.52.0/23 and not net 185.34.107.0/24"
title Sniffin' my babies IPs.   ^|IP:!PS3_IP_ADDRESS!^|   ^|MAC:!PS3_MAC_ADDRESS!^|   ^|Interface:!interface_%CAPTURE_INTERFACE%!^| - !TITLE_VERSION!
echo Started capturing on network interface "!interface_%CAPTURE_INTERFACE%!" ...
echo:
for /l %%? in () do (
    if exist "!WINDOWS_TSHARK_PATH!" (
        if exist "!WINDOWS_BLACKLIST_PATH!" (
            for %%A in (
                blacklisted_found_
                cache_current_psn_ascii_
                skip_static_
                skip_lookup_
                skip_dynamic_
            ) do (
                for /f "delims==" %%B in ('2^>nul set %%A') do (
                    set "%%~B="
                )
            )
            for %%A in (!lookup_memory_blacklisted_found:`^= !) do (
                set "ip=%%A"
                %@TIMER_T2:?=tmp_clear_vars_timer%
                if !tmp_clear_vars_timer_seconds_%%A! gtr !clear_vars_timer_seconds_max! (
                    set "lookup_memory_blacklisted_found=!lookup_memory_blacklisted_found:`%%A`=!"
                    if not defined lookup_memory_blacklisted_found (
                        set lookup_memory_blacklisted_found=`
                    )
                    for /f "delims==" %%B in ('2^>nul set tmp_ ^| findstr /c:"%%A="') do (
                        set "%%~B="
                    )
                )
            )
            for %%A in (ip skip_ps3_protection) do (
                if defined %%A (
                    set %%A=
                )
            )
            for /f "usebackqdelims==" %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
                if not defined blacklisted_psn_hexadecimal_%%~A (
                    set "blacklisted_psn=%%~A"
                    call :ASCII_TO_HEXADECIMAL
                )
            )
            for /f "tokens=1-8" %%A in ('^"%@WINDOWS_TSHARK_STDERR%"!WINDOWS_TSHARK_PATH!" -q -Q -i !CAPTURE_INTERFACE! -f "!CAPTURE_FILTER!" -Y "frame.len^>^=68 and frame.len^<^=1160" -Tfields -Eseparator^=/s -e ip.src_host -e ip.src -e udp.srcport -e ip.dst_host -e ip.dst -e udp.dstport -e data -e frame.len -a duration:1^"') do (
                if not "%%~H"=="" (
                    set "hexadecimal_packet=%%~G"
                    set "frame_len=%%~H"
                    if defined local_ip_%%~B (
                        set "reverse_ip=%%~D"
                        set "ip=%%~E"
                        set "port=%%~F"
                        call :BLACKLIST_SEARCH src
                    ) else (
                        set "reverse_ip=%%~A"
                        set "ip=%%~B"
                        set "port=%%~C"
                        call :BLACKLIST_SEARCH dst
                    )
                )
            )
        ) else (
            call :CREATE_WINDOWS_BLACKLIST_FILE
        )
    ) else (
        %@MSGBOX% "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' setting on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE_VERSION!"
        exit /b 0
    )
)
exit /b 0

:BLACKLIST_SEARCH
if defined local_ip_%ip% (
    exit /b 0
)
if defined blacklisted_found_%ip% (
    exit /b 0
)
if defined skip_static_%ip% (
    if defined skip_lookup_%ip% (
        if defined skip_dynamic_%ip% (
            exit /b 0
        )
    )
)
if "%ip:~0,8%"=="192.168." (
    set "local_ip_%ip%=1"
    exit /b 0
) else if "%ip:~0,3%"=="10." (
    set "local_ip_%ip%=1"
    exit /b 0
) else if "%ip:~0,4%"=="172." (
    for /l %%A in (16,1,31) do (
        if "%ip:~4,3%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
) else if "%ip:~0,4%"=="100." (
    for /l %%A in (64,1,99) do (
        if "%ip:~4,3%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
    for /l %%A in (100,1,127) do (
        if "%ip:~4,4%"=="%%~A." (
            set "local_ip_%ip%=1"
            exit /b 0
        )
    )
)
if defined current_psn_ascii (
    set current_psn_ascii=
)
if not defined skip_lookup_%ip% (
    if not "!@LOOKUP_PSN_LENGTH:`%frame_len%`=!"=="!@LOOKUP_PSN_LENGTH!" (
        if not "!hexadecimal_packet:FF83FFFEFFFE=!"=="!hexadecimal_packet!" (
            if not "!hexadecimal_packet:707333=!"=="!hexadecimal_packet!" (
                set "psn_hexadecimal=!hexadecimal_packet:*FF83FFFEFFFE=!"
                if %1==src (
                    set "psn_hexadecimal=!psn_hexadecimal:~72,32!"
                ) else (
                    set "psn_hexadecimal=!psn_hexadecimal:~8,32!"
                )
                if defined psn_hexadecimal (
                    set "psn_hexadecimal=!psn_hexadecimal:00=!"
                    if defined psn_hexadecimal (
                        set "skip_lookup_%ip%=1"
                        if defined blacklisted_psn_ascii_!psn_hexadecimal! (
                            for %%A in (!psn_hexadecimal!) do (
                                set blacklisted_psn=!blacklisted_psn_ascii_%%A!
                            )
                            set blacklisted_detection_type=PSN Username
                            call :BLACKLISTED_FOUND
                            exit /b 0
                        )
                        %= resolves the newer username if it has changed for the IP algos below =%
                        if defined cache_current_psn_ascii_!psn_hexadecimal! (
                            for %%A in (!psn_hexadecimal!) do (
                                set current_psn_ascii=!cache_current_psn_ascii_%%A!
                            )
                        ) else (
                            call :HEXADECIMAL_TO_ASCII && (
                                for %%A in (!psn_hexadecimal!) do (
                                    set current_psn_ascii=!cache_current_psn_ascii_%%A!
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)
if not defined skip_static_%ip% (
    set "skip_static_%ip%=1"
    for /f "tokens=1,2delims==" %%A in ('findstr /ec:"=%ip%" "!WINDOWS_BLACKLIST_PATH!"') do (
        if "%ip%"=="%%~B" (
            set "blacklisted_psn=%%~A"
            set blacklisted_detection_type=Static IP
            call :BLACKLISTED_FOUND
            exit /b 0
        )
    )
)
if not defined skip_dynamic_%ip% (
    set "skip_dynamic_%ip%=1"
    call :DETECTION_TYPE_FORM_PRECISION ip dynamic_ip
    for /f "delims==" %%A in ('2^>nul set skip_dynamic_try_') do (
        set "%%~A="
    )
    for /f "tokens=1,2delims==" %%A in ('findstr /c:"=!dynamic_ip!" "!WINDOWS_BLACKLIST_PATH!"') do (
        if not "%%~B"=="" (
            if not defined skip_dynamic_try_%%~B (
                set "skip_dynamic_try_%%~B=1"
                set "x=%%~B"
                call :DETECTION_TYPE_FORM_PRECISION x blacklisted_dynamic_ip
                if "!dynamic_ip!"=="!blacklisted_dynamic_ip!" (
                    if not exist "lib\tmp\dynamic_iplookup_%ip%.tmp" (
                        call :IPLOOKUP dynamic %ip%
                    )
                    if not exist "lib\tmp\blacklisted_iplookup_%%~B.tmp" (
                        call :IPLOOKUP blacklisted %%~B
                    )
                    if defined dynamic_iplookup_dif (
                        set dynamic_iplookup_dif=
                    )
                    for /f "usebackqtokens=1*delims==" %%C in ("lib\tmp\dynamic_iplookup_%ip%.tmp") do (
                        for /f "usebackqtokens=1*delims==" %%E in ("lib\tmp\blacklisted_iplookup_%%~B.tmp") do (
                            if "%%~C"=="%%~E" (
                                if not "%%~D"=="%%~F" (
                                    if not "%%~C"=="status" (
                                        if not "%%~C"=="message" (
                                            if not "%%~C"=="reverse" (
                                                if not "%%~C"=="query" (
                                                    if not "%%~C"=="proxy_2" (
                                                        if not "%%~C"=="type" (
                                                            set dynamic_iplookup_dif=1
                                                        )
                                                    )
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                    if not defined dynamic_iplookup_dif (
                        set "blacklisted_psn=%%~A"
                        set blacklisted_detection_type=Dynamic IP ^(bad accuracy*^)
                        call :BLACKLISTED_FOUND
                        exit /b 0
                    )
                )
            )
        )
    )
)
exit /b 1

:BLACKLISTED_FOUND
for /f "tokens=2delims==." %%A in ('2^>nul wmic os get LocalDateTime /value') do (
    set "datetime=%%A"
    set "datetime=!datetime:~0,-10!-!datetime:~-10,2!-!datetime:~-8,2!_!datetime:~-6,2!-!datetime:~-4,2!-!datetime:~-2!"
    set "hourtime=!datetime:~11,2!:!datetime:~14,2!"
)
if not defined blacklisted_found_%ip% (
    set /a blacklisted_found_%ip%=1, tmp_clear_vars_timer_seconds_%ip%=0
    if "!lookup_memory_blacklisted_found:`%ip%`=!"=="!lookup_memory_blacklisted_found!" (
        set "lookup_memory_blacklisted_found=!lookup_memory_blacklisted_found!%ip%`"
    )
    %@TIMER_T1:?=tmp_clear_vars_timer%
)
for %%A in (blacklisted_psn current_psn_ascii) do (
    if defined %%A (
        >nul findstr /xc:"!%%A!=%ip%" "!WINDOWS_BLACKLIST_PATH!" || (
            call :CHECK_FILE_NEWLINE WINDOWS_BLACKLIST_PATH
            >>"!WINDOWS_BLACKLIST_PATH!" (
                !@write_newline!
                echo !%%A!=%ip%
            ) || (
                call :ERROR_FATAL WRITING_FAILURE_OR_INVALID_FILENAME WINDOWS_BLACKLIST_PATH
            )
        )
    )
)
if not defined tmp_blacklisted_iplookup_%ip% (
    call :IPLOOKUP blacklisted %ip%
)
set blacklisted_psn_list_counter=1
set "@blacklisted_psn_list=[%blacklisted_psn%]"
set "@ps3_blacklisted_psn_list=%%5B%blacklisted_psn%%%5D"
for /f "delims==" %%A in ('findstr /bc:"%blacklisted_psn%=" "!WINDOWS_BLACKLIST_PATH!"') do (
    if "%%~A"=="%blacklisted_psn%" (
        if "!@blacklisted_psn_list:[%%~A]=!"=="!@blacklisted_psn_list!" (
            set /a blacklisted_psn_list_counter+=1
            set "@blacklisted_psn_list=!@blacklisted_psn_list!, [%%~A]"
            set "@ps3_blacklisted_psn_list=!@ps3_blacklisted_psn_list!,+%%5B%%~A%%5D"
        )
    )
)
for /f "tokens=1,2delims==" %%A in ('findstr /ec:"=%ip%" "!WINDOWS_BLACKLIST_PATH!"') do (
    if "%%~B"=="%ip%" (
        if "!@blacklisted_psn_list:[%%~A]=!"=="!@blacklisted_psn_list!" (
            set /a blacklisted_psn_list_counter+=1
            set "@blacklisted_psn_list=!@blacklisted_psn_list!, [%%~A]"
            set "@ps3_blacklisted_psn_list=!@ps3_blacklisted_psn_list!,+%%5B%%~A%%5D"
        )
    )
)
if !blacklisted_psn_list_counter! gtr 1 (
    set "@ps3_psn_plurial_asterisk=%%2A"
    set "@psn_plurial_asterisk=*"
) else (
    set @ps3_psn_plurial_asterisk=
    set @psn_plurial_asterisk=
)
echo User!@psn_plurial_asterisk!:!@blacklisted_psn_list! ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!tmp_blacklisted_iplookup_countrycode_%ip%! ^| Detection Type: !blacklisted_detection_type!
:LOOP_WINDOWS_RESULTS_LOGGING_PATH
if %WINDOWS_RESULTS_LOGGING%==true (
    call :CHECK_FILE_NEWLINE WINDOWS_RESULTS_LOGGING_PATH
    >>"%WINDOWS_RESULTS_LOGGING_PATH%" (
        !@write_newline!
        echo User!@psn_plurial_asterisk!:!@blacklisted_psn_list! ^| ReverseIP:%reverse_ip% ^| IP:%ip% ^| Port:%port% ^| Time:!datetime! ^| Country:!tmp_blacklisted_iplookup_countrycode_%ip%! ^| Detection Type: !blacklisted_detection_type!
    ) || (
        call :CREATE_WINDOWS_RESULTS_LOGGING_FILE
        goto :LOOP_WINDOWS_RESULTS_LOGGING_PATH
    )
)
if %WINDOWS_NOTIFICATIONS%==true (
    if defined skip_windows_notifications (
        set skip_windows_notifications=
    )
    if %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL%==true (
        if defined tmp_windows_notifications_packets_interval_t1_%ip% (
            %@TIMER_T2:?=tmp_windows_notifications_packets_interval%
        ) else (
            set tmp_windows_notifications_packets_interval_seconds_%ip%=%WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER%
        )
        if !tmp_windows_notifications_packets_interval_seconds_%ip%! lss %WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER% (
            set skip_windows_notifications=1
        )
        %@TIMER_T1:?=tmp_windows_notifications_packets_interval%
    )
    if not defined skip_windows_notifications (
        if defined tmp_windows_notifications_t1_%ip% (
            %@TIMER_T2:?=tmp_windows_notifications%
        ) else (
            set tmp_windows_notifications_seconds_%ip%=%WINDOWS_NOTIFICATIONS_TIMER%
        )
        if !tmp_windows_notifications_seconds_%ip%! geq %WINDOWS_NOTIFICATIONS_TIMER% (
            set tmp_windows_notifications_t1_%ip%=
            %@MSGBOX_B% "##### Blacklisted user detected at !hourtime:~0,5! #####!\N!!\N!User!@psn_plurial_asterisk!: !@blacklisted_psn_list!!\N!IP: %ip%!\N!Port: %port%!\N!Country Code: !tmp_blacklisted_iplookup_countrycode_%ip%!!\N!Detection Type: !blacklisted_detection_type!!\N!!\N!############# IP Lookup ##############!\N!!\N!Reverse IP: !tmp_blacklisted_iplookup_reverse_%ip%!!\N!Continent: !tmp_blacklisted_iplookup_continent_%ip%!!\N!Country: !tmp_blacklisted_iplookup_country_%ip%!!\N!City: !tmp_blacklisted_iplookup_city_%ip%!!\N!Organization: !tmp_blacklisted_iplookup_org_%ip%!!\N!ISP: !tmp_blacklisted_iplookup_isp_%ip%!!\N!AS: !tmp_blacklisted_iplookup_as_%ip%!!\N!AS Name: !tmp_blacklisted_iplookup_asname_%ip%!!\N!Proxy: !tmp_blacklisted_iplookup_proxy_2_%ip%!!\N!Type: !tmp_blacklisted_iplookup_type_%ip%!!\N!Mobile (cellular) connection: !tmp_blacklisted_iplookup_mobile_%ip%!!\N!Proxy, VPN or Tor exit address: !tmp_blacklisted_iplookup_proxy_%ip%!!\N!Hosting, colocated or data center: !tmp_blacklisted_iplookup_hosting_%ip%!" 69680 "!TITLE_VERSION!"
            if not defined tmp_windows_notifications_t1_%ip% (
                %@TIMER_T1:?=tmp_windows_notifications%
            )
        )
    )
)
if defined PS3_IP_ADDRESS (
    if not defined skip_ps3_protection (
        set skip_ps3_protection=1
        if not %PS3_PROTECTION%==false (
            if %PS3_PROTECTION%==Reload_Game (
                >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/xmb.ps3$reloadgame" && (
                    if %PS3_NOTIFICATIONS%==true (
                        >nul timeout /t 25 /nobreak
                    )
                )
            ) else if %PS3_PROTECTION%==Exit_Game (
                >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/xmb.ps3$exit" && (
                    if %PS3_NOTIFICATIONS%==true (
                        >nul timeout /t 15 /nobreak
                    )
                )
            ) else if %PS3_PROTECTION%==Restart_PS3 (
                >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/restart.ps3" && (
                    exit /b
                )
            ) else if %PS3_PROTECTION%==Shutdown_PS3 (
                >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/shutdown.ps3" && (
                    exit /b
                )
            )
        )
    )
    if %PS3_NOTIFICATIONS%==true (
        if %PS3_NOTIFICATIONS_ABOVE%==true (
            if defined skip_ps3_notifications_above (
                set skip_ps3_notifications_above=
            )
            if %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL%==true (
                if defined tmp_ps3_notifications_above_packets_interval_t1_%ip% (
                    %@TIMER_T2:?=tmp_ps3_notifications_above_packets_interval%
                ) else (
                    set tmp_ps3_notifications_above_packets_interval_seconds_%ip%=%PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER%
                )
                if !tmp_ps3_notifications_above_packets_interval_seconds_%ip%! lss %PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER% (
                    set skip_ps3_notifications_above=1
                )
                %@TIMER_T1:?=tmp_ps3_notifications_above_packets_interval%
            )
            if not defined skip_ps3_notifications_above (
                if defined tmp_ps3_notifications_above_t1_%ip% (
                    %@TIMER_T2:?=tmp_ps3_notifications_above%
                ) else (
                    set tmp_ps3_notifications_above_seconds_%ip%=%PS3_NOTIFICATIONS_ABOVE_TIMER%
                )
                if !tmp_ps3_notifications_above_seconds_%ip%! geq %PS3_NOTIFICATIONS_ABOVE_TIMER% (
                    set tmp_ps3_notifications_above_t1_%ip%=
                    if not %PS3_NOTIFICATIONS_ABOVE_SOUND%==false (
                        set first_3=1
                    )
                    for /l %%A in (1,1,3) do (
                        if defined first_3 (
                            set first_3=
                            set "@PS3_NOTIFICATIONS_ABOVE_SOUND=&snd=%PS3_NOTIFICATIONS_ABOVE_SOUND%"
                        ) else (
                            if defined @PS3_NOTIFICATIONS_ABOVE_SOUND (
                                set @PS3_NOTIFICATIONS_ABOVE_SOUND=
                            )
                        )
                        >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/notify.ps3mapi?msg=Blacklisted+user!@ps3_psn_plurial_asterisk!+%%5B%blacklisted_psn%%%5D+detected%%3A%%0D%%0AIP%%3A+%ip%%%0D%%0APort%%3A+%port%%%0D%%0ACountry%%3A+!tmp_blacklisted_iplookup_countrycode_%ip%!&icon=!PS3_NOTIFICATIONS_ABOVE_ICON!!@PS3_NOTIFICATIONS_ABOVE_SOUND!"
                    )
                    if not defined tmp_ps3_notifications_above_t1_%ip% (
                        %@TIMER_T1:?=tmp_ps3_notifications_above%
                    )
                )
            )
        )
        if %PS3_NOTIFICATIONS_BOTTOM%==true (
            if defined skip_ps3_notifications_bottom (
                set skip_ps3_notifications_bottom=
            )
            if %PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL%==true (
                if defined tmp_ps3_notifications_bottom_packets_interval_t1_%ip% (
                    %@TIMER_T2:?=tmp_ps3_notifications_bottom_packets_interval%
                ) else (
                    set tmp_ps3_notifications_bottom_packets_interval_seconds_%ip%=%PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER%
                )
                if !tmp_ps3_notifications_bottom_packets_interval_seconds_%ip%! lss %PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER% (
                    set skip_ps3_notifications_bottom=1
                )
                %@TIMER_T1:?=tmp_ps3_notifications_bottom_packets_interval%
            )
            if not defined skip_ps3_notifications_bottom (
                if defined tmp_ps3_notifications_bottom_t1_%ip% (
                    %@TIMER_T2:?=tmp_ps3_notifications_bottom%
                ) else (
                    set tmp_ps3_notifications_bottom_seconds_%ip%=%PS3_NOTIFICATIONS_BOTTOM_TIMER%
                )
                if !tmp_ps3_notifications_bottom_seconds_%ip%! geq %PS3_NOTIFICATIONS_BOTTOM_TIMER% (
                    set tmp_ps3_notifications_bottom_t1_%ip%=
                    >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/popup.ps3*Blacklisted+user!@ps3_psn_plurial_asterisk!%%3A+!@ps3_blacklisted_psn_list!+connected..."
                    if not %PS3_NOTIFICATIONS_BOTTOM_SOUND%==false (
                        >nul curl.exe -fks "http://%PS3_IP_ADDRESS%/beep.ps3?%PS3_NOTIFICATIONS_BOTTOM_SOUND%"
                    )
                    if not defined tmp_ps3_notifications_bottom_t1_%ip% (
                        %@TIMER_T1:?=tmp_ps3_notifications_bottom%
                    )
                )
            )
        )
    )
)
exit /b

:CHECK_FILE_NEWLINE
if defined @write_newline (
    set @write_newline=
)
if exist "!%1!" (
    <"!%1!" >nul (
        for %%A in ("!%1!") do (
            for /l %%. in (2 1 %%~zA) do (
                pause
            )
            set /p @write_newline=
        )
    )
    if defined @write_newline (
        set "@write_newline=echo:"
    ) else (
        set @write_newline=
    )
)
exit /b

:DETECTION_TYPE_FORM_PRECISION
for /f "tokens=1-3delims=." %%A in ("!%1!") do (
    if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==1 (
        set "%2=%%~A"
    ) else if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==2 (
        set "%2=%%~A.%%~B"
    ) else if %DETECTION_TYPE_DYNAMIC_IP_PRECISION%==3 (
        set "%2=%%~A.%%~B.%%~C"
    )
)
exit /b

:ASCII_TO_HEXADECIMAL
if defined blacklisted_psn_hexadecimal_%blacklisted_psn% (
    exit /b 0
)
if not "%blacklisted_psn:~16%"=="" (
    exit /b 1
)
if "%blacklisted_psn:~2%"=="" (
    exit /b 1
)
for /f "delims=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" %%A in ("%blacklisted_psn%") do (
    exit /b 1
)
if exist "lib\tmp\blacklisted_psn_hexadecimal.tmp" (
    for /f "tokens=1,2delims==" %%A in ('findstr /bc:"%blacklisted_psn%=" "lib\tmp\blacklisted_psn_hexadecimal.tmp"') do (
        if not "%%~B"=="" (
            if "%%~A"=="%blacklisted_psn%" (
                set "blacklisted_psn_hexadecimal_%blacklisted_psn%=%%~B"
                call :CHECK_PSN_HEXADECIMAL && (
                    set blacklisted_psn_ascii_!blacklisted_psn_hexadecimal_%blacklisted_psn%!=%blacklisted_psn%
                    exit /b 0
                )
                set "blacklisted_psn_hexadecimal_%blacklisted_psn%="
            )
        )
    )
)
for /l %%A in (0,1,15) do (
    for %%B in (!blacklisted_psn:~%%A^,1!) do (
        set _current=!#MAP_ASCII_TO_HEX:*#%%B=!
        if not !_current:~0^,1!==%%B (
            set _current=!_current:*#%%B=!
        )
        set blacklisted_psn_hexadecimal_%blacklisted_psn%=!blacklisted_psn_hexadecimal_%blacklisted_psn%!!_current:~1,2!
    )
)
set _current=
set blacklisted_psn_ascii_!blacklisted_psn_hexadecimal_%blacklisted_psn%!=%blacklisted_psn%
for %%A in ("lib\tmp\blacklisted_psn_hexadecimal.tmp") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || (
            call :ERROR_FATAL WRITING_FAILURE "%%~dpA"
        )
    )
    set "write_newline_file_path=%%~A"
    call :CHECK_FILE_NEWLINE write_newline_file_path
    set write_newline_file_path=
    >>"%%~A" (
        !@write_newline!
        echo %blacklisted_psn%=!blacklisted_psn_hexadecimal_%blacklisted_psn%!
    ) || (
        call :ERROR_FATAL WRITING_FAILURE "%%~A"
    )
)
exit /b 0

:CHECK_PSN_HEXADECIMAL
if not "!blacklisted_psn_hexadecimal_%blacklisted_psn%:~32!"=="" (
    exit /b 1
)
if "!blacklisted_psn_hexadecimal_%blacklisted_psn%:~5!"=="" (
    exit /b 1
)
for /f "delims=abcdefABCDEF0123456789" %%A in ("!blacklisted_psn_hexadecimal_%blacklisted_psn%!") do (
    exit /b 1
)
exit /b 0

:HEXADECIMAL_TO_ASCII
if not "%psn_hexadecimal:~32%"=="" (
    exit /b 1
)
if "%psn_hexadecimal:~5%"=="" (
    exit /b 1
)
for /f "delims=abcdefABCDEF0123456789" %%A in ("%psn_hexadecimal%") do (
    exit /b 1
)
for /l %%A in (0,2,30) do (
    for %%B in (!psn_hexadecimal:~%%A^,2!) do (
        set _current=!#MAP_HEX_TO_ASCII:*#%%B=!
        set cache_current_psn_ascii_%psn_hexadecimal%=!cache_current_psn_ascii_%psn_hexadecimal%!!_current:~0,1!
    )
)
set _current=
exit /b 0

:IPLOOKUP
set "tmp_%1_iplookup_%2=1"
if exist "lib\tmp\%1_iplookup_%2.tmp" (
    for /f "usebackqtokens=1*delims==" %%A in ("lib\tmp\%1_iplookup_%2.tmp") do (
        if not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~A`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
            set "tmp_%1_iplookup_%%~A_%2=%%~B"
        )
    )
) else (
    for /f "tokens=1,2delims=</" %%A in ('curl.exe -fks "http://ip-api.com/xml/%2?fields=status,message,continent,continentCode,country,countryCode,region,regionName,city,district,zip,lat,lon,timezone,offset,currency,isp,org,as,asname,reverse,mobile,proxy,hosting,query"') do (
        set "x=%%~A%%~B"
        set "x=!x:~2!"
        for /f "tokens=1,2delims=>" %%C in ("!x!") do (
            if not "%%~D"=="" (
                if not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~C`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
                    set "tmp_%1_iplookup_%%~C_%2=%%~D"
                )
            )
        )
    )
    if "%~1"=="blacklisted" (
        for /f "tokens=1,2delims=:" %%A in ('curl.exe -fks "https://proxycheck.io/v2/%2?vpn=1&port=1"') do (
            set "x=%%~A:%%~B"
            set "x=!x:"=!"
            if "!x:~-1!"=="," (
                set "x=!x:~0,-1!"
            )
            set "x=!x:proxy=proxy_2!"
            set "x=!x:no=false!"
            set "x=!x:yes=true!"
            for /f "tokens=1,2delims=: " %%C in ("!x!") do (
                if not "%%~D"=="" (
                    if not "!@LOOKUP_IPLOOKUP_FIELDS:`%%~C`=!"=="!@LOOKUP_IPLOOKUP_FIELDS!" (
                        set "tmp_%1_iplookup_%%~C_%2=%%~D"
                    )
                )
            )
        )
    )
    for %%A in ("lib\tmp\%1_iplookup.tmp") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || (
                call :ERROR_FATAL WRITING_FAILURE "%%~dpA"
            )
        )
    )
    for %%A in (%@LOOKUP_IPLOOKUP_FIELDS:`=,%) do (
        if not defined tmp_%1_iplookup_%%~A_%2 (
            set "tmp_%1_iplookup_%%~A_%2=N/A"
        )
        >>"lib\tmp\%1_iplookup_%2.tmp" (
            echo %%~A=!tmp_%1_iplookup_%%~A_%2!
        ) || (
            call :ERROR_FATAL WRITING_FAILURE "%%~A"
        )
    )
)
call :CHECK_COUNTRYCODE %1 %2 || (
    for /f "tokens=1,2delims=:, " %%A in ('curl.exe -fks "https://ipinfo.io/%2/json"') do (
        if /i "%%~A"=="country" (
            set "tmp_%1_iplookup_countrycode_%2=%%~B"
            call :CHECK_COUNTRYCODE %1 %2 || (
                set "tmp_%1_iplookup_countrycode_%2="
            )
        )
    )
)
exit /b

:CHECK_COUNTRYCODE
if defined tmp_%1_iplookup_countrycode_%2 (
    if "!tmp_%1_iplookup_countrycode_%2:~1!"=="!tmp_%1_iplookup_countrycode_%2:~-1!" (
        exit /b 0
    )
)
exit /b 1

:CREATE_WINDOWS_TSHARK_PATH
call :CHECK_WINDOWS_TSHARK_PATH && (
    exit /b 0
)
call :GET_WINDOWS_TSHARK_PATH && (
    set _WINDOWS_TSHARK_PATH=
    if not defined generate_new_settings_file (
        set generate_new_settings_file=1
    )
    exit /b 0
)
%@MSGBOX% "!TITLE! could not find your 'WINDOWS_TSHARK_PATH' setting on your system.!\N!!\N!Redirecting you to Wireshark download page.!\N!!\N!You can also define your own PATH in the 'Settings.ini' file." 69648 "!TITLE_VERSION!"
start "" "https://www.wireshark.org/#download"
if exist "Settings.ini" (
    notepad.exe "Settings.ini"
)
exit /b 1

:CREATE_WINDOWS_BLACKLIST_FILE
call :CHECK_PATH_EXIST WINDOWS_BLACKLIST_PATH || (
    for %%A in ("!WINDOWS_BLACKLIST_PATH!") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || (
                call :ERROR_FATAL WRITING_FAILURE_OR_INVALID_FILENAME WINDOWS_BLACKLIST_PATH
            )
        )
        >"%%~A" (
            echo ;;-----------------------------------------------------------------------
            echo ;;Lines starting with ";;" symbols are commented lines.
            echo ;;
            echo ;;This is the blacklist file for 'PS3 Blacklist Sniffer' configuration.
            echo ;;
            echo ;;Please leave their exact ^<PSN USERNAME^>.
            echo ;;This makes it possible to perform the username search
            echo ;;if they changed their ^<IP ADDRESS^>.
            echo ;;
            echo ;;Your blacklist MUST be formatted in the following way in order to work:
            echo ;;^<PSN USERNAME^>=^<IP ADDRESS^>
            echo ;;-----------------------------------------------------------------------
        ) || (
            call :ERROR_FATAL WRITING_FAILURE_OR_INVALID_FILENAME WINDOWS_BLACKLIST_PATH
        )
    )
)
exit /b

:CREATE_WINDOWS_RESULTS_LOGGING_FILE
call :CHECK_PATH_EXIST WINDOWS_RESULTS_LOGGING_PATH || (
    for %%A in ("!WINDOWS_RESULTS_LOGGING_PATH!") do (
        if not exist "%%~dpA" (
            md "%%~dpA" || (
                call :ERROR_FATAL WRITING_FAILURE_OR_INVALID_FILENAME WINDOWS_RESULTS_LOGGING_PATH
            )
        )
        >"%%~A" (
            set x=
        ) || (
            call :ERROR_FATAL WRITING_FAILURE_OR_INVALID_FILENAME WINDOWS_RESULTS_LOGGING_PATH
        )
    )
)
exit /b

:CREATE_SETTINGS_FILE
>"Settings.ini" (
    echo ;;-----------------------------------------------------------------------------
    echo ;;Lines starting with ";;" symbols are commented lines.
    echo ;;
    echo ;;This is the settings file for 'PS3 Blacklist Sniffer' configuration.
    echo ;;
    echo ;;If you do not know what to choose, the program automatically
    echo ;;analyzes it and will regenerate this file if it contains errors.
    echo ;;
    echo ;;^<PATH^>
    echo ;;The Windows path where your file is located.
    echo ;;
    echo ;;^<WINDOWS_TSHARK_STDERR^>
    echo ;;The 'tshark.exe' error text output from the console.
    echo ;;
    echo ;;^<NOTIFICATIONS^>
    echo ;;Get notified when a blacklisted user is found.
    echo ;;
    echo ;;^<WINDOWS_RESULTS_LOGGING^>
    echo ;;Logs the results of the command prompt console on your computer disk.
    echo ;;
    echo ;;^<IP_ADDRESS^>
    echo ;;Your PS3 console IP address. You can obtain it from your PS3 console:
    echo ;;Settings^>Network Settings^>Settings and Connection Status List^>IP Address
    echo ;;Valid example value: 'x.x.x.x'
    echo ;;
    echo ;;^<MAC_ADDRESS^>
    echo ;;Your PS3 console MAC address. You can obtain it from your PS3 console:
    echo ;;Settings^>Network Settings^>Settings and Connection Status List^>MAC Address
    echo ;;Valid example value:'xx:xx:xx:xx:xx:xx'
    echo ;;
    echo ;;^<PROTECTION^>
    echo ;;Action to perform when a blacklisted user is found.
    echo ;;Set it to 'false' to disable it or pick one from:
    echo ;;'Reload_Game'
    echo ;;'Exit_Game'
    echo ;;'Restart_PS3'
    echo ;;'Shutdown_PS3'
    echo ;;
    echo ;;^<PACKETS_INTERVAL^>
    echo ;;Time interval between which this will not display a notification
    echo ;;if the packets are still received from the blacklisted user.
    echo ;;
    echo ;;^<TIMER^>
    echo ;;Time interval between which this will display a notification.
    echo ;;Your PS3 console may crash if you send it too many notifications.
    echo ;;If you are having this problem, I recommend that you increase
    echo ;;the number of the ^<TIMER^> causing spamming.
    echo ;;
    echo ;;^<ICON^>
    echo ;;The icon to display for your PS3 console notifications.
    echo ;;However, the icons only works on the XMB home screen.
    echo ;;
    echo ;;^<SOUND^>
    echo ;;The notification sound for your PS3 console when a blacklisted user is found.
    echo ;;Valid values are '0-9' and 'false' to disable.
    echo ;;
    echo ;;^<DETECTION_TYPE^>
    echo ;;The detection types used to lookup and detect the blacklisted users.
    echo ;;Those can be: 'PSN_USERNAME', 'STATIC_IP' and 'DYNAMIC_IP'.
    echo ;;
    echo ;;^<DETECTION_TYPE_DYNAMIC_IP_PRECISION^>
    echo ;;The chosen number of octet^(s^) that will be used for the Dynamic IP lookup.
    echo ;;Valid values are '1-3'.
    echo ;;-----------------------------------------------------------------------------
    echo WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!
    echo WINDOWS_TSHARK_STDERR=!WINDOWS_TSHARK_STDERR!
    echo WINDOWS_BLACKLIST_PATH=!WINDOWS_BLACKLIST_PATH!
    echo WINDOWS_RESULTS_LOGGING=!WINDOWS_RESULTS_LOGGING!
    echo WINDOWS_RESULTS_LOGGING_PATH=!WINDOWS_RESULTS_LOGGING_PATH!
    echo WINDOWS_NOTIFICATIONS=!WINDOWS_NOTIFICATIONS!
    echo WINDOWS_NOTIFICATIONS_TIMER=!WINDOWS_NOTIFICATIONS_TIMER!
    echo WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL=!WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL!
    echo WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER=!WINDOWS_NOTIFICATIONS_PACKETS_INTERVAL_TIMER!
    echo PS3_IP_AND_MAC_ADDRESS_AUTOMATIC=!PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!
    echo PS3_IP_ADDRESS=!PS3_IP_ADDRESS!
    echo PS3_MAC_ADDRESS=!PS3_MAC_ADDRESS!
    echo PS3_PROTECTION=!PS3_PROTECTION!
    echo PS3_NOTIFICATIONS=!PS3_NOTIFICATIONS!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON!
    echo PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE=!PS3_NOTIFICATIONS_ABOVE!
    echo PS3_NOTIFICATIONS_ABOVE_ICON=!PS3_NOTIFICATIONS_ABOVE_ICON!
    echo PS3_NOTIFICATIONS_ABOVE_SOUND=!PS3_NOTIFICATIONS_ABOVE_SOUND!
    echo PS3_NOTIFICATIONS_ABOVE_TIMER=!PS3_NOTIFICATIONS_ABOVE_TIMER!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_ABOVE_PACKETS_INTERVAL_TIMER!
    echo PS3_NOTIFICATIONS_BOTTOM=!PS3_NOTIFICATIONS_BOTTOM!
    echo PS3_NOTIFICATIONS_BOTTOM_SOUND=!PS3_NOTIFICATIONS_BOTTOM_SOUND!
    echo PS3_NOTIFICATIONS_BOTTOM_TIMER=!PS3_NOTIFICATIONS_BOTTOM_TIMER!
    echo PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL=!PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL!
    echo PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER=!PS3_NOTIFICATIONS_BOTTOM_PACKETS_INTERVAL_TIMER!
    echo DETECTION_TYPE_DYNAMIC_IP_PRECISION=!DETECTION_TYPE_DYNAMIC_IP_PRECISION!
) || (
    call :ERROR_FATAL WRITING_FAILURE "Settings.ini"
)
exit /b

:GET_WINDOWS_TSHARK_PATH
>nul 2>&1 where "tshark.exe" && (
    for /f "delims=" %%A in ('where "tshark.exe"') do (
        if defined WINDOWS_TSHARK_PATH (
            set "PREVIOUS_WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!"
        )
        set "WINDOWS_TSHARK_PATH=%%~A"
        if not "!PREVIOUS_WINDOWS_TSHARK_PATH!"=="!WINDOWS_TSHARK_PATH!" (
            call :CHECK_WINDOWS_TSHARK_PATH && (
                exit /b 0
            )
        )
    )
)
for %%A in (A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z) do (
    if exist "%%A:\Program Files\Wireshark\tshark.exe" (
        if defined WINDOWS_TSHARK_PATH (
            set "PREVIOUS_WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!"
        )
        set "WINDOWS_TSHARK_PATH=%%A:\Program Files\Wireshark\tshark.exe"
        if not "!PREVIOUS_WINDOWS_TSHARK_PATH!"=="!WINDOWS_TSHARK_PATH!" (
            call :CHECK_WINDOWS_TSHARK_PATH && (
                exit /b 0
            )
        )
    )
)
for %%A in (
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Wireshark.exe"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\App Paths\Wireshark.exe"
    "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Wireshark"
    "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Wireshark"
    "HKLM\SOFTWARE\Classes\wireshark-capture-file\DefaultIcon"
    "HKLM\SOFTWARE\Classes\wireshark-capture-file\Shell\open\command"
    "HKCR\wireshark-capture-file\Shell\open\command"
    "HKCR\wireshark-capture-file\DefaultIcon"
) do (
    for /f "delims=,%%" %%B in ('2^>nul reg query "%%~A" ^| find /i "REG_SZ" ^| find /i "Wireshark.exe"') do (
        if defined WINDOWS_TSHARK_PATH (
            set "PREVIOUS_WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!"
        )
        set "WINDOWS_TSHARK_PATH=%%~B"
        set "WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH:*REG_SZ=!"
        set "WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH:\Wireshark.exe=\tshark.exe!"
        set "PREVIOUS_WINDOWS_TSHARK_PATH=!WINDOWS_TSHARK_PATH!"
        if not "!PREVIOUS_WINDOWS_TSHARK_PATH!"=="!WINDOWS_TSHARK_PATH!" (
            call :CHECK_WINDOWS_TSHARK_PATH && (
                exit /b 0
            )
        )
    )
)
exit /b 1

:PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
if defined PS3_MAC_ADDRESS (
    if not defined PS3_IP_ADDRESS (
        call :PS3_IP_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION PS3_MAC_ADDRESS PS3_IP_ADDRESS && (
            call :CREATE_SETTINGS_FILE
            exit /b
        )
    )
) else if defined PS3_IP_ADDRESS (
    if not defined PS3_MAC_ADDRESS (
        call :PS3_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION PS3_IP_ADDRESS PS3_MAC_ADDRESS && (
            call :CREATE_SETTINGS_FILE
            exit /b
        )
    )
)
if defined PS3_IP_ADDRESS (
    if defined PS3_MAC_ADDRESS (
        for /f "tokens=1,2" %%A in ('ARP -a') do (
            if "%%~A"=="!PS3_IP_ADDRESS!" (
                if not "%%~B"=="!PS3_MAC_ADDRESS::=-!" (
                    set PS3_MAC_ADDRESS=
                    call :CREATE_SETTINGS_FILE
                    exit /b
                )
            )
        )
    )
)
exit /b

:PS3_IP_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
set "%1=!%1::=-!"
for /f "tokens=1,2" %%A in ('ARP -a') do (
    if "!%1!"=="%%~B" (
        set "%2=%%~A"
        set "%1=!%1:-=:!"
        exit /b 0
    )
)
set "%1=!%1:-=:!"
exit /b 1

:PS3_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
for /f "tokens=1,2" %%A in ('ARP -a') do (
    if "!%1!"=="%%~A" (
        set "%2=%%~B"
        set "%2=!%2:-=:!"
        exit /b 0
    )
)
exit /b 1

:CHECK_WINDOWS_TSHARK_PATH
if not defined WINDOWS_TSHARK_PATH (
    exit /b 1
)
call :CHECK_PATH_EXIST WINDOWS_TSHARK_PATH && (
    >nul 2>&1 "!WINDOWS_TSHARK_PATH!" -v && (
        exit /b 0
    )
)
exit /b 1

:CHECK_WEBMAN_MOD_CONNECTION
if !PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!==false (
        set @PS3_NOTIFICATIONS_ABOVE_SOUND=
) else (
    set "@PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND=&snd=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!"
)
for /f %%A in ('curl.exe -fks -w "%%{response_code}" -o NUL "http://!%1!/notify.ps3mapi?msg=!TITLE: =+!+successfully+connected+to+your+PS3+console%%2E&icon=!PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_ICON!!@PS3_NOTIFICATIONS_IP_ADDRESS_CONNECTED_SOUND!"') do (
    if "%%~A"=="200" (
        set ps3_connected_notification=1
        set "PS3_IP_ADDRESS=!%1!"
        set "PS3_MAC_ADDRESS=!%2!"
        if !PS3_IP_AND_MAC_ADDRESS_AUTOMATIC!==true (
            call :PS3_IP_AND_MAC_ADDRESS_AUTOMATIC_ARP_ATTRIBUTION
        )
        exit /b 0
    )
    exit /b 1
)
exit /b 1

:MSGBOX_GENERATION
for %%A in ("lib\msgbox.vbs") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || (
            call :ERROR_FATAL WRITING_FAILURE "%%~dpA"
        )
    )
    >"%%~A" (
        echo MsgBox WScript.Arguments^(0^),WScript.Arguments^(1^),WScript.Arguments^(2^)
    ) || (
        call :ERROR_FATAL WRITING_FAILURE "%%~A"
    )
)
exit /b

:CHECK_PATH_EXIST
if not defined %1 exit /b 1
set "%1=!%1:"=!"
if not defined %1 exit /b 1
set "%1=!%1:/=\!"
:CHECK_PATH_EXIST_STRIP_WHITE_SPACES
if "!%1:~0,1!"==" " (
set "%1=!%1:~1!"
if not defined %1 exit /b 1
goto :CHECK_PATH_EXIST_STRIP_WHITE_SPACES
)
:_CHECK_PATH_STRIP_WHITE_SPACES
if "!%1:~-1!"==" " (
set "%1=!%1:~0,-1!"
if not defined %1 exit /b 1
goto :_CHECK_PATH_STRIP_WHITE_SPACES
)
:CHECK_PATH_EXIST_STRIP_SLASHES
if not "!%1:\\=!"=="!%1!" (
set "%1=!%1:\\=\!"
if not defined %1 exit /b 1
goto :CHECK_PATH_EXIST_STRIP_SLASHES
)
if exist "!%1!" exit /b 0
exit /b 1

:CHECK_NUMBER
if not defined %1 (
    exit /b 1
)
for /f "delims=0123456789" %%A in ("!%1!") do (
    exit /b 1
)
:CHECK_NUMBER_STRIP_STARTING_ZERO
if "!%1:~0,1!"=="0" (
    if not "!%1:~1,1!"=="" (
        set "%1=!%1:~1!"
        if not defined generate_new_settings_file (
            set generate_new_settings_file=1
        )
        goto :CHECK_NUMBER_STRIP_STARTING_ZERO
    )
)
exit /b 0

:CHECK_IP
if not defined %1 exit /b 1
if "!%1!"=="!%1:~0,6!" exit /b 1
if not "!%1!"=="!%1:..=!" exit /b 1
for /f "tokens=1-5delims=." %%A in ("!%1!") do (
if not "%%E"=="" exit /b 1
call :CHECK_BETWEEN0AND255 "%%~A" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~B" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~C" || exit /b 1
call :CHECK_BETWEEN0AND255 "%%~D" || exit /b 1
)
exit /b 0

:CHECK_BETWEEN0AND255
if "%~1"=="" exit /b 1
for /f "delims=0123456789" %%A in ("%~1") do exit /b 1
if %~1 lss 0 exit /b 1
if %~1 gtr 255 exit /b 1
exit /b 0

:CHECK_MAC
if not defined %1 exit /b 1
if "!%1!"=="!%1:~0,16!" exit /b 1
if not "!%1!"=="!%1:::=!" exit /b 1
for /f "tokens=1-7delims=:" %%A in ("!%1!") do (
if not "%%G"=="" exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~A" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~B" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~C" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~D" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~E" || exit /b 1
call :CHECK_BETWEEN0ANDZ "%%~F" || exit /b 1
)
exit /b 0

:CHECK_BETWEEN0ANDZ
if "%~1"=="" exit /b 1
set "x=%~1"
if not "!x:~1!"=="" if "!x:~2!"=="" for /f "delims=0123456789abcdefABCDEF" %%A in ("%~1") do exit /b 1
exit /b 0

:GET_FILE_ATTRIBUTES
if not exist "%~1" (
    exit /b
)
for %%A in ("%~1") do (
    set "attributes=%%~aA"
)
for /f "delims=" %%A in ('2^>nul attrib "%~1"') do (
    set "_attributes=%%A"
)
for /f "tokens=1*delims=:" %%A in ("$!_attributes!") do (
    if not "%%B"=="" (
        set "_attributes=%%A"
        set "_attributes=!_attributes:~1,-1!"
        if defined _attributes (
            set "attributes=!attributes!!_attributes!"
        )
    )
    if defined _attributes (
        set _attributes=
    )
)
if defined attributes (
    for %%A in (-," ") do (
        if defined attributes (
            set "attributes=!attributes:%%~A=!"
        )
    )
    if defined attributes (
        for /f "delims==" %%A in ('2^>nul set attribute_[') do (
            set %%A=
        )
        for /l %%A in (0,1,51) do (
            for %%B in ("!attributes:~%%A,1!") do (
                if not "%%~B"=="" (
                    for %%C in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
                        if /i "%%C"=="%%~B" (
                            if not defined attribute_[%%C] (
                                set attribute_[%%C]=1
                                if defined _attributes (
                                    if "!_attributes:%%C=!"=="!_attributes!" (
                                        set "_attributes=!_attributes!%%C"
                                    )
                                ) else (
                                    set "_attributes=%%C"
                                )
                            )
                        )
                    )
                )
            )
        )
        set "attributes=!_attributes!"
    )
)
exit /b

:UPDATER
for /f "delims=" %%A in ('curl.exe -fks "https://raw.githubusercontent.com/Illegal-Services/PS3-Blacklist-Sniffer/version/version.txt"') do (
    set "last_version=%%~A"
    goto :JUMP_3
)
:JUMP_3
if not defined last_version (
    exit /b 1
)
if "!VERSION:~1,5!" geq "!last_version:~1,5!" (
    exit /b 0
)
if defined OLD_VERSION (
    if defined OLD_LAST_VERSION (
        if "!OLD_VERSION!"=="!VERSION!" (
            if "!OLD_LAST_VERSION!"=="!last_version!" (
                exit /b 0
            )
        )
    )
)
for %%A in ("lib\msgbox_updater.vbs") do (
    if not exist "%%~dpA" (
        md "%%~dpA" || (
            call :ERROR_FATAL WRITING_FAILURE "%%~dpA"
        )
    )
    >"%%~A" (
        echo Dim Response
        echo Response=MsgBox^(WScript.Arguments^(0^),WScript.Arguments^(1^),WScript.Arguments^(2^)^)
        echo If Response=vbYes then
        echo wscript.quit 6
        echo End If
        echo wscript.quit 7
    ) || (
        call :ERROR_FATAL WRITING_FAILURE "%%~A"
    )
)
cscript //nologo "lib\msgbox_updater.vbs" "New version found. Do you want to update ?!\N!!\N!Current version: !VERSION!!\N!Latest version   : !last_version!" 69668 "!TITLE_VERSION! Updater"
if not !errorlevel!==6 (
    exit /b 0
)
if exist "[UPDATED]_PS3_Blacklist_Sniffer.bat" (
    del /f /q /a "[UPDATED]_PS3_Blacklist_Sniffer.bat" || (
        exit /b 1
    )
)
curl.exe -f#ko "[UPDATED]_PS3_Blacklist_Sniffer.bat" "https://raw.githubusercontent.com/Illegal-Services/PS3-Blacklist-Sniffer/main/PS3_Blacklist_Sniffer.bat" && (
    >nul move /y "[UPDATED]_PS3_Blacklist_Sniffer.bat" "%~f0" && (
        call "%~f0" && (
            exit 0
        )
    )
)
exit /b 1

:ERROR_FATAL
if "%~1"=="WRITING_FAILURE" (
    call :GET_FILE_ATTRIBUTES "%~2"
    if defined attributes (
        if not "!attributes:R=!"=="!attributes!" (
            mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' to your disk at this location because it is in read-only."",69648,""!TITLE_VERSION!"":close"^)
            exit 0
        )
    )
    >nul 2>&1 dism || (
        mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' to your disk at this location because it does not have administrator permissions."" & Chr(10) & Chr(10) & ""Run '%~nx0' as administrator and try again."",69648,""!TITLE_VERSION!"":close"^)
        exit 0
    )
    mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' to your disk at this location for an unknown reason."",69648,""!TITLE_VERSION!"":close"^)
    exit 0
) else if "%~1"=="WRITING_FAILURE_OR_INVALID_FILENAME" (
    call :GET_FILE_ATTRIBUTES "!%2!"
    if defined attributes (
        if not "!attributes:R=!"=="!attributes!" (
            mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' in 'Settings.ini' to your disk at this location because it is in read-only."",69648,""!TITLE_VERSION!"":close"^)
            exit 0
        )
    )
    >nul 2>&1 dism || (
        mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' in 'Settings.ini' to your disk at this location because it does not have administrator permissions."" & Chr(10) & Chr(10) & ""Run '%~nx0' as administrator and try again."",69648,""!TITLE_VERSION!"":close"^)
        exit 0
    )
    mshta vbscript:Execute^("msgbox ""!TITLE! cannot write '%~2' in 'Settings.ini' to your disk at this location for an unknown reason or it's custom PATH you've entered is invalid."",69648,""!TITLE_VERSION!"":close"^)
    exit 0
)
exit 0
