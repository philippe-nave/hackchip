10 REM
20 REM Analyze data file for CHIP's CHALLENGE
30 REM
40 OPEN "chips.dat" FOR RANDOM ACCESS READ AS #1 LEN=1
50 FIELD #1,1 AS Q$
60 REM
70 GOSUB 1320:REM get run options
80 REM
90 PKT=1
91 if d$="P" then GOSUB 1460:REM page header
92 if d$="F" then open "hackchip.rpt" for output as #2
100 REM
110 REM Bytes 5 and 6 contain maximum level number (lo-hi)
120 REM
130 GET #1,5:LOMX$=Q$:GET #1,6:HIMX$=Q$:MX=(ASC(LOMX$)+(256*(ASC(HIMX$))))
140 if d$="P" then LPRINT "Highest level : ";MX:LKT=LKT+1
150 REM
160 REM Now we begin with the game maps. First two bytes are the offset to
170 REM the next game map.
180 REM
190 NEXTPTR=7:REM first level's data starts here
200 CURPTR=NEXTPTR:GOSUB 230:REM tell us about the current level
210 IF (CLEVEL < MX) THEN 200
211 if d$="F" then close #2
215 CLS
220 CLOSE #1:END
230 REM
240 REM Explain the current level, as well as save data for next level
250 REM
251 IF ((d$="P") and (LKT > 55)) THEN GOSUB 1460
260 if d$="P" then LPRINT:LKT=LKT+1
261 if d$="F" then print#2,""
270 SVPTR=CURPTR:REM save start pointer for this level
280 REM
290 REM First two bytes are offset to next level (lo-hi)
300 REM
310 GET #1,(CURPTR):OFL=ASC(Q$):GET #1,(CURPTR+1):OFH=ASC(Q$)
320 OFFSET=OFL+(256*OFH):NEXTPTR=SVPTR+OFFSET+2
330 CURPTR=CURPTR+2
340 REM
350 REM Next two bytes are the level number (lo-hi)
360 REM
370 GET #1,(CURPTR):LNL=ASC(Q$):GET #1,(CURPTR+1):LNH=ASC(Q$)
380 CLEVEL=LNL+(256*LNH)
390 CURPTR=CURPTR+2
400 if d$="P" then LPRINT USING "Level ###:";CLEVEL;
401 if d$="F" then print#2,"Level ";CLEVEL;" ";
405 LOCATE 16,25:PRINT USING "Printing data for level ###";CLEVEL
410 REM
420 REM Next two bytes are the time limit in seconds (lo-hi). 0=no limit.
430 REM
440 GET #1,(CURPTR):TML=ASC(Q$):GET #1,(CURPTR+1):TMH=ASC(Q$)
450 TIMELIM=TML+(256*TMH)
460 REM PRINT USING "Time:###  ";TIMELIM;
470 CURPTR=CURPTR+2
480 REM
490 REM Next two bytes are the number of chips to get (lo-hi)
500 REM
510 GET #1,(CURPTR):NCL=ASC(Q$):GET #1,(CURPTR+1):NCH=ASC(Q$)
520 NCHIPS=NCL+(256*NCH)
530 REM PRINT USING "Chips:###  ";NCHIPS;
540 REM
550 REM Wild-ass guess about floor mapping, part I - skip floor plan.
560 REM
570 CURPTR=CURPTR+4
580 GET #1,(CURPTR):FLJL=ASC(Q$):GET #1,(CURPTR+1):FLJH=ASC(Q$)
590 FLJMP=FLJL+(256*FLJH):IF (FLJMP+CURPTR+2)>NEXTPTR THEN STOP
600 REM PRINT USING "Floor Jump: ######  ";FLJMP;
610 CURPTR=CURPTR+FLJMP+2
620 REM PRINT USING "New pointer: ######  ";CURPTR;
630 REM
640 REM Wild-ass guess, part II.
650 REM
660 GET #1,(CURPTR):FLL=ASC(Q$):GET #1,(CURPTR+1):FLH=ASC(Q$)
670 FJ2=FLL+(256*FLH):CURPTR=CURPTR+FJ2+4
680 REM
690 REM
700 REM Now we're starting into the known variables.
710 REM
720 GET #1,(CURPTR):I=ASC(Q$):IF I<>3 THEN 830
730 CURPTR=CURPTR+1:GET #1,(CURPTR):TL=ASC(Q$)
731 if d$="P" then LPRINT CHR$(34);
732 if d$="F" then print#2,chr$(34);
740 FOR I=1 TO (TL-1)
750 CURPTR=CURPTR+1:GET #1,(CURPTR):T$=Q$
751 if d$="P" then LPRINT T$;
752 if d$="F" then print#2,t$;
760 NEXT I
761 if d$="P" then LPRINT CHR$(34);
762 if d$="P" then LPRINT USING "  Time Limit:### Seconds (0=no limit)";TIMELIM;
763 if d$="P" then LPRINT USING "  Chips:###";NCHIPS:LKT=LKT+1
764 if d$="F" then print#2,chr$(34);
765 if d$="F" then print#2," Time Limit: ";TIMELIM;" seconds ";
766 if d$="F" then print#2,"Chips:";nchips
770 REM
780 REM See if there is any help text for this level..
790 REM
800 CURPTR=CURPTR+1:GET #1,(CURPTR):I=ASC(Q$)
810 IF I<>0 THEN PRINT "Shit!":CLOSE #1:END
820 CURPTR=CURPTR+1
830 GET #1,(CURPTR):I=ASC(Q$):IF I<> 7 THEN 940
840 CURPTR=CURPTR+1:GET #1,(CURPTR):HL=ASC(Q$)
841 CKT=0
850 FOR I=1 TO (HL-1)
860 CURPTR=CURPTR+1:GET #1,(CURPTR):T$=Q$
861 if d$="P" then LPRINT T$;
862 if d$="F" then print#2,t$;
863 CKT=CKT+1:IF CKT <= 75 THEN 870
864 if d$="P" then LPRINT
865 if d$="F" then print#2,""
866 CKT=1:LKT=LKT+1
870 NEXT I
871 if d$="P" then lprint:LKT=LKT+1
872 if d$="F" then print#2,""
880 REM
890 REM Password should be next...
900 REM
910 CURPTR=CURPTR+1:GET #1,(CURPTR):I=ASC(Q$)
920 IF I<>0 THEN PRINT "Shit!":CLOSE #1:END
930 CURPTR=CURPTR+1
940 GET #1,(CURPTR):I=ASC(Q$):IF I<>6 THEN 1000
950 CURPTR=CURPTR+1:GET #1,(CURPTR):PL=ASC(Q$)
951 if d$="P" then LPRINT "Password : ";
952 if d$="F" then print#2,"Password : ";
960 FOR I=1 TO (PL-1)
970 CURPTR=CURPTR+1:GET #1,(CURPTR):CRP=ASC(Q$):GOSUB 1010
971 if d$="P" then LPRINT CLC$;
972 if d$="F" then print#2,CLC$;
980 NEXT I
1000 LKT=LKT+1
1001 if d$="P" then LPRINT
1002 if d$="F" then print#2,""
1003 RETURN
1010 REM
1020 REM Subroutine for decrypting a password character
1030 REM
1040 CLC$="?":CRH$=HEX$(CRP)
1050 IF CRH$="D8" THEN CLC$="A"
1060 IF CRH$="DB" THEN CLC$="B"
1070 IF CRH$="DA" THEN CLC$="C"
1080 IF CRH$="DD" THEN CLC$="D"
1090 IF CRH$="DC" THEN CLC$="E"
1100 IF CRH$="DF" THEN CLC$="F"
1110 IF CRH$="DE" THEN CLC$="G"
1120 IF CRH$="D1" THEN CLC$="H"
1130 IF CRH$="D0" THEN CLC$="I"
1140 IF CRH$="D3" THEN CLC$="J"
1150 IF CRH$="D2" THEN CLC$="K"
1160 IF CRH$="D5" THEN CLC$="L"
1170 IF CRH$="D4" THEN CLC$="M"
1180 IF CRH$="D7" THEN CLC$="N"
1190 IF CRH$="D6" THEN CLC$="O"
1200 IF CRH$="C9" THEN CLC$="P"
1210 IF CRH$="C8" THEN CLC$="Q"
1220 IF CRH$="CB" THEN CLC$="R"
1230 IF CRH$="CA" THEN CLC$="S"
1240 IF CRH$="CD" THEN CLC$="T"
1250 IF CRH$="CC" THEN CLC$="U"
1260 IF CRH$="CF" THEN CLC$="V"
1270 IF CRH$="CE" THEN CLC$="W"
1280 IF CRH$="C1" THEN CLC$="X"
1290 IF CRH$="C0" THEN CLC$="Y"
1300 IF CRH$="C3" THEN CLC$="Z"
1310 RETURN
1320 KEY OFF:CLS:LOCATE 5,25:PRINT "Hacking Chip's Challenge"
1330 LOCATE 7,10:PRINT "This program will read the CHIPS.DAT file that contains"
1340 LOCATE 8,10:PRINT "all the levels of the CHIP'S CHALLENGE game and print a"
1350 LOCATE 9,10:PRINT "detailed report of all levels, passwords, time limits,"
1360 LOCATE 10,10:PRINT "chip counts, and help text. This report will be sent"
1370 LOCATE 11,10:PRINT "to your line printer. If you do not want to proceed,"
1380 LOCATE 12,10:PRINT "stop now."
1390 LOCATE 14,25:PRINT "Continue? (Y/N) : ":LOCATE 14,43,1
1400 L$=INKEY$:IF L$="" THEN 1400
1410 IF L$="n" OR L$="N" THEN CLS:END
1420 IF L$="y" OR L$="Y" THEN 1440
1430 PRINT CHR$(7);:GOTO 1390
1440 LOCATE 14,43:PRINT "Y"
1441 locate 15,25:print "Send report to (P)rinter or (F)ile : ":locate 15,62
1442 d$=inkey$:if d$="" then 1442
1443 if d$="P" or d$="p" then d$="P":goto 1446
1444 if d$="F" or d$="f" then d$="F":goto 1446
1445 print chr$(7);:goto 1441
1446 locate 15,62:print d$
1450 RETURN
1460 REM
1470 REM Print page header
1471 rem
1480 if d$="F" then return
1481 IF PKT>1 THEN LPRINT CHR$(12)
1490 LPRINT USING "&                  Hacking Chip's Challenge                   Page ###";DATE$,PKT
1500 LPRINT
1505 LKT=2:PKT=PKT+1
1510 RETURN
