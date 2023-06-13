.386
;Задайте объём ПЗУ в байтах
RomSize    EQU   1000h                   ;4Кб для программного кода

           NMax = 50                     ;Число повторений при вводе с кнопки

           SensFirePort1 = 00FEh         ;Порт ввода состояния датчиков пожара - этаж 1 
           SensFirePort2 = 00FDh         ;Порт ввода состояния датчиков пожара - этаж 2
           SensBrechPort1 = 00FBh        ;Порт ввода состояния датчиков взлома - этаж 1 
           SensBrechPort2 = 00F7h        ;Порт ввода состояния датчиков взлома - этаж 2

           SecureBtnPort1 = 00EFh        ;Порт ввода кнопок постановки комнат под охрану - этаж 1 
           SecureBtnPort2 = 00DFh        ;Порт ввода кнопок постановки комнат под охрану - этаж 2
		   
           CtrlBtnPort = 00BFh           ;Порт ввода с кнопок управления индикацией

           RoomIndPort1 = 00EFh          ;Адрес 1-го порта вывода для двоичных индикаторов - этаж 1
           RoomIndPort2 = 00DFh          ;Адрес 2-го порта вывода для двоичных индикаторов - этаж 2 

           CtrlIndPort = 00BFh           ;Порт управления звонком и индикаторами режимов

           AlarmTime =  20               ;Длительность включения звонка
           PulseTime = 20                ;Длительность включения при мигании индикаторов     
           PauseTime = 20                ;Длительность паузы при мигании индикаторов

Data       SEGMENT use16 AT 0040h 
;Здесь размещаются описания переменных

           AlarmFlag  db ?               ;Флаг управления звонком (;Флаг общей тревоги)
           IndFlag db ?                  ;Флаг формирования свечения индикаторов всех охраняемых комнат и комнат где 
           FadeFlag db ?                 ;Флаг формирования свечения индикаторов охраняемых комнат в которых не сработали датчики  

           SensFireStatus  db 2 dup (?)  ;Состояние датчиков пожара
           SensBreachStatus  db 2 dup (?);Состояние датчиков взлома
           SecureRoomBtn db 2 dup (?)    ;Состояние кнопок постановки комнат под охрану
           CtrlBtnStatus db ?            ;Состояние кнопок управления индикацией и звонком - биты 0, 1, 2, 3 
				
           SecureOrFireStatus db 2 dup (?)    ;Комнаты, находящиеся под охраной или комнаты в которых сработали датчики пожара      
           BreachOrFireStatus db 2 dup (?)    ;Комнаты в которых сработали датчики 1 этаж (мл. байт) и 2 этаж (ст. байт)
           SecureAndBreachStatus db 2 dup (?) ;Комнаты находящиеся под охраной, в которых сработали датчики взлома
      
           CountAlarm dw ?               ;Длительность включения тревоги
           CountPause dw ?               ;Длительность паузы при мигании индикаторов
           CountPulse dw ?               ;Длительность включения при мигании индикаторов       
        
Data       ENDS

;Задайте необходимый адрес стека
Stk        SEGMENT use16 AT 60h 
;Задайте необходимый размер стека
           dw    32 dup (?)
StkTop     Label Word
Stk        ENDS

InitData   SEGMENT use16
InitDataStart:
;Здесь размещаются описания констант
InitDataEnd:
InitData   ENDS

Code       SEGMENT use16
       ASSUME cs:Code,ds:Data,ss:Stk
;Здесь размещаются описания программных модулей 
               
FuncPrep Proc 
          
           mov word ptr SecureRoomBtn,0        ;Вначале все кнопки не нажаты
           mov word ptr SensFireStatus,0       ;Вначале все датчики пожара не активны 
           mov word ptr SensBreachStatus,0     ;Вначале все датчики взлома не активны 
           mov word ptr SecureOrFireStatus,0   ;все комнаты в порядке
           mov word ptr BreachOrFireStatus, 0 
           mov word ptr SecureAndBreachStatus, 0
             
           mov AlarmFlag,0               ;Флаг управления звонком     
           mov IndFlag, 0FFh             ;Флаг формирования интервала 1 установлен
           mov FadeFlag,0                ;Флаг формирования интервала 2 сброшен

           mov CountAlarm, AlarmTime     ;Длительность включения звонка
           mov CountPause, PauseTime     ;Длительность паузы при мигании индикаторов
           mov CountPulse, PulseTime     ;Длительность включения при мигании индикаторов 
		   
           call Flashing                 ;Сигнализация начала работы устройства
		   
           ret
FuncPrep Endp

Flashing PROC 
;Выключить на короткое время звонок и сигнал на пульт пожарной охраны

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
          
;Подмодуль "Гашение дребезга кнопок"
VibrDelete  PROC  NEAR
vd1:       mov   ah,al                   ;Сохранение исходного состояния
           mov   cl,0                    ;Сброс счётчика повторений
vd2:       in    al,dx                   ;Ввод текущего состояния
           cmp   ah,al                   ;Текущее состояние=исходному?
           jnz   vd1                     ;Переход, если нет
           inc   cl                      ;Инкремент счётчика повторений
           cmp   cl,NMax                 ;Конец дребезга?
           jnz   vd2                     ;Переход, если нет
           mov   al,ah                   ;Восстановление местоположения данных
           
           ret
VibrDelete  ENDP

SecureButtonsInput Proc
;ввод состояния кнопок постановки комнат под охрану 
           lea bx,SecureRoomBtn          ;Массив состояния кнопок
           mov dx,SecureBtnPort1
           in al,dx	                     ;Ввод из порта
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [bx], al                  ;Сохранить состояние кнопок постановки комнат под охрану - этаж 1
           
           mov dx,SecureBtnPort2
           in	al,dx	                 ;Ввод из порта
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [bx+1], al                ;Сохранить состояние кнопок постановки комнат под охрану - этаж 2
           
           ret
SecureButtonsInput endp

CtrlBtnInput Proc
;ввод состояния кнопок управления индикацией       
           mov dx,CtrlBtnPort
           in	al,dx                    ;Ввод из порта
           call	VibrDelete               ;Гашение дребезга
           mov  CtrlBtnStatus, al        ;Сохранить состояние кнопок 
           
           ret          
CtrlBtnInput Endp

SensBreachInput Proc ;ввод с датчиков взлома
           lea si,SensBreachStatus       ;Массив состояния датчиков
		   
           mov dx,SensBrechPort1 ;SensBrechPort1 - Адрес порта ввода (этаж 1)
           in	al,dx                    ;Ввод из порта		   
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [si], al                  ;Сохранить состояние  датчиков взлома - этаж 1
                     
           mov dx,SensBrechPort2         ;SensBrechPort2 - Адрес порта ввода (этаж 2)
           in	al,dx	                 ;Ввод из порта
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [si+1], al                ;Сохранить состояние  датчиков взлома - этаж 2
           
           mov ax, Word ptr SensBreachStatus

           ret
SensBreachInput endp

SensFireInput Proc ;ввод с датчиков пожара
           lea si,SensFireStatus         ;Массив состояния датчиков
           mov dx,SensFirePort1          ;SensFirePort1 - Адрес порта ввода (этаж 1)
           in	al,dx                    ;Ввод из порта		   
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [si], al                  ;Сохранить состояние  датчиков пожара - этаж 1
                     
           mov dx,SensFirePort2          ;SensFirePort2 - Адрес порта ввода (этаж 2)
           in	al,dx	                 ;Ввод из порта	   
           call	VibrDelete               ;Гашение дребезга
           not al
           mov [si+1], al                ;Сохранить состояние  датчиков пожара - этаж 2
		   
           mov ax, Word ptr SensFireStatus

           ret
SensFireInput endp

SecureOrFireForm Proc 
;формирование массива охраняемых комнат и всех комнат, где пожар
           mov ax,word ptr SensFireStatus        ;датчики пожара
           mov dx,word ptr SecureRoomBtn         ;охраняемые комнаты
           or ax,dx
           mov word ptr SecureOrFireStatus,ax    ;сохранить
         
           ret
SecureOrFireForm Endp

;формирование массива комнат где сработали датчики
BreachOrFireForm Proc 
           mov ax,word ptr SensFireStatus        ;датчики пожара
           mov dx,word ptr SensBreachStatus      ;датчики взлома
           or ax,dx
           mov word ptr BreachOrFireStatus,ax    ;сохранить комнаты где сработали датчики
         
           ret
BreachOrFireForm Endp

SecureAndBreachForm PROC 
           mov ax,word ptr SensBreachStatus      ;датчики взлома
           mov dx,word ptr SecureRoomBtn         ;комната под охраной
           and ax,dx
           mov word ptr SecureAndBreachStatus,ax ;сохранить охраняемые комнаты где сработали датчики взлома
           
           ret
SecureAndBreachForm ENDP

;Модуль "Формирование флаг тревоги"
AlarmForm Proc
           cmp word ptr SensFireStatus, 0        ;есть пожар в любой из комнат
           jnz m1                                ;да
           cmp word ptr SecureAndBreachStatus, 0 ;есть взлом в охраняемой комнате
           jz AlarmOff                           ;нет
                                                 ;да, реализовать временную задержку
m1:        dec word ptr CountAlarm               ;декремент счетчика числа проходов
           cmp word ptr CountAlarm,0             ;все проходы?
           jnz AlarmOut                       ;нет, ничего не делать
                                                 ;да, задержка закончилась         
           mov CountAlarm,AlarmTime              ;перезагрузить счетчик числа проходов
           not AlarmFlag                         ;Инвертировать флаг управления звонком
           jmp AlarmOut                          ;На выход
AlarmOff:   
           mov AlarmFlag,0                   
AlarmOut:   
           ret
AlarmForm Endp

SecureOrFireInd PROC 
;свечение индикаторов охраняемых комнат и всех комнат, где пожар

           cmp IndFlag,0FFh              
           jnz IndOut 

           cmp CtrlBtnStatus, 0FFh       ;нажаты кнопки "пожар" или "взлом"
           jnz IndOut					 ;да, выходим

		   mov al, SecureOrFireStatus
           out RoomIndPort1, al
           mov al, SecureOrFireStatus+1
           out RoomIndPort2, al
			
           dec word ptr CountPause       ;Декремент счетчика числа проходов 
           jnz IndOut                    ;Больше ничего не делаем. если не все проходы
                                         ;все проходы
           mov IndFlag,0
           mov FadeFlag,0FFh
           mov CountPause,PauseTime      ;Перезагрузить счетчик числа проходов
IndOut:           
           ret
SecureOrFireInd ENDP

BreachOrFireFade PROC
;свечение индикаторов охраняемых комнат, где нет тревоги
;гашение индикаторов комнат, где сработали датчики

           cmp FadeFlag,0FFh             
           jnz FadeOut
           
           cmp CtrlBtnStatus, 0FFh       ;нажаты кнопки "пожар" или "взлом"
           jnz FadeOut                   ;да
		   
           mov ax, word ptr BreachOrFireStatus
           not ax
           mov dx, word ptr SecureRoomBtn
           and ax, dx

           out RoomIndPort1, al           ;выводим все охрвняемые комнаты где не сработали датчики 
           xchg ah, al
           out RoomIndPort2, al
			
           dec word ptr CountPulse        ;Декремент счетчика числа проходов 
           jnz FadeOut                    ;Ничего не делаем. если не все проходы
                                          ;все проходы
           mov FadeFlag,0
           mov IndFlag,0FFh      
           mov CountPulse,PulseTime       ;Перезагрузить счетчик числа проходов                      
FadeOut:  
           ret
BreachOrFireFade ENDP

ControlOutput PROC 
;Вывод на индикаторы режима отображения  
 
           mov al, CtrlBtnStatus
           not al
		   
           cmp AlarmFlag, 0FFh                 ;Включить звонок?
           jnz m1                              ;Нет, не нужно включать
		   
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
 
Start:     ;системная подготовка
           mov   ax,Data
           mov   ds,ax
           mov   ax,Stk
           mov   ss,ax
           lea   sp,StkTop
           
;Здесь размещается код программы
           call FuncPrep                 ;Функциональная подготовка    
cycle:     
;ввод
           call SecureButtonsInput       ;Ввод с кнопок постановки под охрану
           call CtrlBtnInput             ;Ввод с кнопок управления
			
           call SensBreachInput          ;ввод с датчиков взлома
           call SensFireInput            ;ввод с датчиков пожара           
;обработка
           call SecureOrFireForm         ;формирование массива охраняемых комнаты или комнат, в которых сработали датчики пожара
           call BreachOrFireForm         ;формирование массива комнат в которых сработали датчики
           call SecureAndBreachForm      ;формирование массива охраняемых комнаты, в которых сработали датчики взлома
			
           call AlarmForm                ;формирование флага тревоги (звонка)           
;вывод
           call SecureOrFireInd          ;свечение индикаторов охраняемых комнат и всех комнат, где пожар
           call BreachOrFireFade         ;пауза в свечении индикаторов комнат, где сработали датчики 
           
           call ControlOutput            ;Вывод на индикаторы режима отображения и звонок
           
           call BreachOutput             ;вывод комнат при нажатии на кнопку "взлом"
           call FireOutput               ;вывод комнат при нажатии на кнопку "пожар"
           
           jmp cycle                     ;зациклить
           
;В следующей строке необходимо указать смещение стартовой точки
           org   RomSize-16-((InitDataEnd-InitDataStart+15) and 0FFF0h)
           ASSUME cs:NOTHING
           jmp   Far Ptr Start
Code       ENDS
END		Start