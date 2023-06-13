.386
;������ ���� ��� � �����
RomSize    EQU   1000h                   ;4�� ��� �ணࠬ����� ����

           NMax = 50                     ;��᫮ ����७�� �� ����� � ������

           SensFirePort1 = 00FEh         ;���� ����� ���ﭨ� ���稪�� ����� - �⠦ 1 
           SensFirePort2 = 00FDh         ;���� ����� ���ﭨ� ���稪�� ����� - �⠦ 2
           SensBrechPort1 = 00FBh        ;���� ����� ���ﭨ� ���稪�� ������ - �⠦ 1 
           SensBrechPort2 = 00F7h        ;���� ����� ���ﭨ� ���稪�� ������ - �⠦ 2

           SecureBtnPort1 = 00EFh        ;���� ����� ������ ���⠭���� ������ ��� ��࠭� - �⠦ 1 
           SecureBtnPort2 = 00DFh        ;���� ����� ������ ���⠭���� ������ ��� ��࠭� - �⠦ 2
		   
           CtrlBtnPort = 00BFh           ;���� ����� � ������ �ࠢ����� ������樥�

           RoomIndPort1 = 00EFh          ;���� 1-�� ���� �뢮�� ��� ������� �������஢ - �⠦ 1
           RoomIndPort2 = 00DFh          ;���� 2-�� ���� �뢮�� ��� ������� �������஢ - �⠦ 2 

           CtrlIndPort = 00BFh           ;���� �ࠢ����� ������� � �������ࠬ� ०����

           AlarmTime =  20               ;���⥫쭮��� ����祭�� ������
           PulseTime = 20                ;���⥫쭮��� ����祭�� �� ������� �������஢     
           PauseTime = 20                ;���⥫쭮��� ���� �� ������� �������஢

Data       SEGMENT use16 AT 0040h 
;����� ࠧ������� ���ᠭ�� ��६�����

           AlarmFlag  db ?               ;���� �ࠢ����� ������� (;���� ��饩 �ॢ���)
           IndFlag db ?                  ;���� �ନ஢���� ᢥ祭�� �������஢ ��� ��࠭塞�� ������ � ������ ��� 
           FadeFlag db ?                 ;���� �ନ஢���� ᢥ祭�� �������஢ ��࠭塞�� ������ � ������ �� �ࠡ�⠫� ���稪�  

           SensFireStatus  db 2 dup (?)  ;����ﭨ� ���稪�� �����
           SensBreachStatus  db 2 dup (?);����ﭨ� ���稪�� ������
           SecureRoomBtn db 2 dup (?)    ;����ﭨ� ������ ���⠭���� ������ ��� ��࠭�
           CtrlBtnStatus db ?            ;����ﭨ� ������ �ࠢ����� ������樥� � ������� - ���� 0, 1, 2, 3 
				
           SecureOrFireStatus db 2 dup (?)    ;�������, ��室�騥�� ��� ��࠭�� ��� ������� � ������ �ࠡ�⠫� ���稪� �����      
           BreachOrFireStatus db 2 dup (?)    ;������� � ������ �ࠡ�⠫� ���稪� 1 �⠦ (��. ����) � 2 �⠦ (��. ����)
           SecureAndBreachStatus db 2 dup (?) ;������� ��室�騥�� ��� ��࠭��, � ������ �ࠡ�⠫� ���稪� ������
      
           CountAlarm dw ?               ;���⥫쭮��� ����祭�� �ॢ���
           CountPause dw ?               ;���⥫쭮��� ���� �� ������� �������஢
           CountPulse dw ?               ;���⥫쭮��� ����祭�� �� ������� �������஢       
        
Data       ENDS

;������ ����室��� ���� �⥪�
Stk        SEGMENT use16 AT 60h 
;������ ����室��� ࠧ��� �⥪�
           dw    32 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;����� ࠧ������� ���ᠭ�� ����⠭�
InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
       ASSUME cs:Code,ds:Data,ss:Stk
;����� ࠧ������� ���ᠭ�� �ணࠬ���� ���㫥� 
               
FuncPrep Proc 
          
           mov word ptr SecureRoomBtn,0        ;���砫� �� ������ �� ������
           mov word ptr SensFireStatus,0       ;���砫� �� ���稪� ����� �� ��⨢�� 
           mov word ptr SensBreachStatus,0     ;���砫� �� ���稪� ������ �� ��⨢�� 
           mov word ptr SecureOrFireStatus,0   ;�� ������� � ���浪�
           mov word ptr BreachOrFireStatus, 0 
           mov word ptr SecureAndBreachStatus, 0
             
           mov AlarmFlag,0               ;���� �ࠢ����� �������     
           mov IndFlag, 0FFh             ;���� �ନ஢���� ���ࢠ�� 1 ��⠭�����
           mov FadeFlag,0                ;���� �ନ஢���� ���ࢠ�� 2 ��襭

           mov CountAlarm, AlarmTime     ;���⥫쭮��� ����祭�� ������
           mov CountPause, PauseTime     ;���⥫쭮��� ���� �� ������� �������஢
           mov CountPulse, PulseTime     ;���⥫쭮��� ����祭�� �� ������� �������஢ 
		   
           call Flashing                 ;����������� ��砫� ࠡ��� ���ன�⢠
		   
           ret
FuncPrep Endp

Flashing PROC 
;�몫���� �� ���⪮� �६� ������ � ᨣ��� �� ���� ����୮� ��࠭�

           mov al, 0FFh
           out RoomIndPort1, al
           out RoomIndPort2, al
           out CtrlIndPort, al
			
           mov dx, 0010h
           mov bx, 0000h 
DDelay0:
           sub bx, 1  
           sbb dx, 0   
           mov si, bx
           or si, dx
           jnz DDelay0
			
           mov al, 0
           out RoomIndPort1, al
           out RoomIndPort2, al
           out CtrlIndPort, al
						
           ret
Flashing ENDP
          
;�������� "��襭�� �ॡ���� ������"
VibrDelete  PROC  NEAR
vd1:       mov   ah,al                   ;���࠭���� ��室���� ���ﭨ�
           mov   cl,0                    ;���� ����稪� ����७��
vd2:       in    al,dx                   ;���� ⥪�饣� ���ﭨ�
           cmp   ah,al                   ;����饥 ���ﭨ�=��室����?
           jnz   vd1                     ;���室, �᫨ ���
           inc   cl                      ;���६��� ����稪� ����७��
           cmp   cl,NMax                 ;����� �ॡ����?
           jnz   vd2                     ;���室, �᫨ ���
           mov   al,ah                   ;����⠭������� ���⮯�������� ������
           
           ret
VibrDelete  ENDP

SecureButtonsInput Proc
;���� ���ﭨ� ������ ���⠭���� ������ ��� ��࠭� 
           lea bx,SecureRoomBtn          ;���ᨢ ���ﭨ� ������
           mov dx,SecureBtnPort1
           in al,dx	                     ;���� �� ����
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [bx], al                  ;���࠭��� ���ﭨ� ������ ���⠭���� ������ ��� ��࠭� - �⠦ 1
           
           mov dx,SecureBtnPort2
           in	al,dx	                 ;���� �� ����
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [bx+1], al                ;���࠭��� ���ﭨ� ������ ���⠭���� ������ ��� ��࠭� - �⠦ 2
           
           ret
SecureButtonsInput endp

CtrlBtnInput Proc
;���� ���ﭨ� ������ �ࠢ����� ������樥�       
           mov dx,CtrlBtnPort
           in	al,dx                    ;���� �� ����
           call	VibrDelete               ;��襭�� �ॡ����
           mov  CtrlBtnStatus, al        ;���࠭��� ���ﭨ� ������ 
           
           ret          
CtrlBtnInput Endp

SensBreachInput Proc ;���� � ���稪�� ������
           lea si,SensBreachStatus       ;���ᨢ ���ﭨ� ���稪��
		   
           mov dx,SensBrechPort1 ;SensBrechPort1 - ���� ���� ����� (�⠦ 1)
           in	al,dx                    ;���� �� ����		   
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [si], al                  ;���࠭��� ���ﭨ�  ���稪�� ������ - �⠦ 1
                     
           mov dx,SensBrechPort2         ;SensBrechPort2 - ���� ���� ����� (�⠦ 2)
           in	al,dx	                 ;���� �� ����
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [si+1], al                ;���࠭��� ���ﭨ�  ���稪�� ������ - �⠦ 2
           
           mov ax, Word ptr SensBreachStatus

           ret
SensBreachInput endp

SensFireInput Proc ;���� � ���稪�� �����
           lea si,SensFireStatus         ;���ᨢ ���ﭨ� ���稪��
           mov dx,SensFirePort1          ;SensFirePort1 - ���� ���� ����� (�⠦ 1)
           in	al,dx                    ;���� �� ����		   
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [si], al                  ;���࠭��� ���ﭨ�  ���稪�� ����� - �⠦ 1
                     
           mov dx,SensFirePort2          ;SensFirePort2 - ���� ���� ����� (�⠦ 2)
           in	al,dx	                 ;���� �� ����	   
           call	VibrDelete               ;��襭�� �ॡ����
           not al
           mov [si+1], al                ;���࠭��� ���ﭨ�  ���稪�� ����� - �⠦ 2
		   
           mov ax, Word ptr SensFireStatus

           ret
SensFireInput endp

SecureOrFireForm Proc 
;�ନ஢���� ���ᨢ� ��࠭塞�� ������ � ��� ������, ��� �����
           mov ax,word ptr SensFireStatus        ;���稪� �����
           mov dx,word ptr SecureRoomBtn         ;��࠭塞� �������
           or ax,dx
           mov word ptr SecureOrFireStatus,ax    ;��࠭���
         
           ret
SecureOrFireForm Endp

;�ନ஢���� ���ᨢ� ������ ��� �ࠡ�⠫� ���稪�
BreachOrFireForm Proc 
           mov ax,word ptr SensFireStatus        ;���稪� �����
           mov dx,word ptr SensBreachStatus      ;���稪� ������
           or ax,dx
           mov word ptr BreachOrFireStatus,ax    ;��࠭��� ������� ��� �ࠡ�⠫� ���稪�
         
           ret
BreachOrFireForm Endp

SecureAndBreachForm PROC 
           mov ax,word ptr SensBreachStatus      ;���稪� ������
           mov dx,word ptr SecureRoomBtn         ;������ ��� ��࠭��
           and ax,dx
           mov word ptr SecureAndBreachStatus,ax ;��࠭��� ��࠭塞� ������� ��� �ࠡ�⠫� ���稪� ������
           
           ret
SecureAndBreachForm ENDP

;����� "��ନ஢���� 䫠� �ॢ���"
AlarmForm Proc
           cmp word ptr SensFireStatus, 0        ;���� ����� � �� �� ������
           jnz m1                                ;��
           cmp word ptr SecureAndBreachStatus, 0 ;���� ����� � ��࠭塞�� ������
           jz AlarmOff                           ;���
                                                 ;��, ॠ�������� �६����� ����প�
m1:        dec word ptr CountAlarm               ;���६��� ���稪� �᫠ ��室��
           cmp word ptr CountAlarm,0             ;�� ��室�?
           jnz AlarmOut                       ;���, ��祣� �� ������
                                                 ;��, ����প� �����稫���         
           mov CountAlarm,AlarmTime              ;��१���㧨�� ���稪 �᫠ ��室��
           not AlarmFlag                         ;������஢��� 䫠� �ࠢ����� �������
           jmp AlarmOut                          ;�� ��室
AlarmOff:   
           mov AlarmFlag,0                   
AlarmOut:   
           ret
AlarmForm Endp

SecureOrFireInd PROC 
;ᢥ祭�� �������஢ ��࠭塞�� ������ � ��� ������, ��� �����

           cmp IndFlag,0FFh              
           jnz IndOut 

           cmp CtrlBtnStatus, 0FFh       ;������ ������ "�����" ��� "�����"
           jnz IndOut					 ;��, ��室��

		   mov al, SecureOrFireStatus
           out RoomIndPort1, al
           mov al, SecureOrFireStatus+1
           out RoomIndPort2, al
			
           dec word ptr CountPause       ;���६��� ���稪� �᫠ ��室�� 
           jnz IndOut                    ;����� ��祣� �� ������. �᫨ �� �� ��室�
                                         ;�� ��室�
           mov IndFlag,0
           mov FadeFlag,0FFh
           mov CountPause,PauseTime      ;��१���㧨�� ���稪 �᫠ ��室��
IndOut:           
           ret
SecureOrFireInd ENDP

BreachOrFireFade PROC
;ᢥ祭�� �������஢ ��࠭塞�� ������, ��� ��� �ॢ���
;��襭�� �������஢ ������, ��� �ࠡ�⠫� ���稪�

           cmp FadeFlag,0FFh             
           jnz FadeOut
           
           cmp CtrlBtnStatus, 0FFh       ;������ ������ "�����" ��� "�����"
           jnz FadeOut                   ;��
		   
           mov ax, word ptr BreachOrFireStatus
           not ax
           mov dx, word ptr SecureRoomBtn
           and ax, dx

           out RoomIndPort1, al           ;�뢮��� �� ��ࢭ塞� ������� ��� �� �ࠡ�⠫� ���稪� 
           xchg ah, al
           out RoomIndPort2, al
			
           dec word ptr CountPulse        ;���६��� ���稪� �᫠ ��室�� 
           jnz FadeOut                    ;��祣� �� ������. �᫨ �� �� ��室�
                                          ;�� ��室�
           mov FadeFlag,0
           mov IndFlag,0FFh      
           mov CountPulse,PulseTime       ;��१���㧨�� ���稪 �᫠ ��室��                      
FadeOut:  
           ret
BreachOrFireFade ENDP

ControlOutput PROC 
;�뢮� �� ��������� ०��� �⮡ࠦ����  
 
           mov al, CtrlBtnStatus
           not al
		   
           cmp AlarmFlag, 0FFh                 ;������� ������?
           jnz m1                              ;���, �� �㦭� �������
		   
           mov dl, 0Ch
           or al, dl
		   
m1:        out CtrlIndPort, al
           ret
ControlOutput ENDP

BreachOutput Proc
           cmp CtrlBtnStatus, 0FEh
           jnz m1
           mov al, SecureAndBreachStatus
           out RoomIndPort1, al
           mov al, SecureAndBreachStatus+1
           out RoomIndPort2, al			
m1:        
           ret
BreachOutput ENDP

FireOutput Proc
           cmp CtrlBtnStatus, 0FDh
           jnz m1
           mov al, SensFireStatus
           out RoomIndPort1, al
           mov al, SensFireStatus+1
           out RoomIndPort2, al	
m1:			
           ret
FireOutput ENDP
 
Start:     ;��⥬��� �����⮢��
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
;����� ࠧ��頥��� ��� �ணࠬ��
           call FuncPrep                 ;�㭪樮���쭠� �����⮢��    
cycle:     
;����
           call SecureButtonsInput       ;���� � ������ ���⠭���� ��� ��࠭�
           call CtrlBtnInput             ;���� � ������ �ࠢ�����
			
           call SensBreachInput          ;���� � ���稪�� ������
           call SensFireInput            ;���� � ���稪�� �����           
;��ࠡ�⪠
           call SecureOrFireForm         ;�ନ஢���� ���ᨢ� ��࠭塞�� ������� ��� ������, � ������ �ࠡ�⠫� ���稪� �����
           call BreachOrFireForm         ;�ନ஢���� ���ᨢ� ������ � ������ �ࠡ�⠫� ���稪�
           call SecureAndBreachForm      ;�ନ஢���� ���ᨢ� ��࠭塞�� �������, � ������ �ࠡ�⠫� ���稪� ������
			
           call AlarmForm                ;�ନ஢���� 䫠�� �ॢ��� (������)           
;�뢮�
           call SecureOrFireInd          ;ᢥ祭�� �������஢ ��࠭塞�� ������ � ��� ������, ��� �����
           call BreachOrFireFade         ;��㧠 � ᢥ祭�� �������஢ ������, ��� �ࠡ�⠫� ���稪� 
           
           call ControlOutput            ;�뢮� �� ��������� ०��� �⮡ࠦ���� � ������
           
           call BreachOutput             ;�뢮� ������ �� ����⨨ �� ������ "�����"
           call FireOutput               ;�뢮� ������ �� ����⨨ �� ������ "�����"
           
           jmp cycle                     ;��横����
           
;� ᫥���饩 ��ப� ����室��� 㪠���� ᬥ饭�� ���⮢�� �窨
           org   RomSize-16-((InitDataEnd-InitDataStart+15) and 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start