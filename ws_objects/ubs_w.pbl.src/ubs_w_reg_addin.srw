$PBExportHeader$ubs_w_reg_addin.srw
$PBExportComments$[jhchoi] 장비입고 - 2009.06.06
forward
global type ubs_w_reg_addin from w_a_reg_m_m
end type
type dw_file from datawindow within ubs_w_reg_addin
end type
type dw_temp from datawindow within ubs_w_reg_addin
end type
type gb_2 from groupbox within ubs_w_reg_addin
end type
type gb_1 from groupbox within ubs_w_reg_addin
end type
type gb_3 from groupbox within ubs_w_reg_addin
end type
end forward

global type ubs_w_reg_addin from w_a_reg_m_m
integer width = 3365
integer height = 1908
dw_file dw_file
dw_temp dw_temp
gb_2 gb_2
gb_1 gb_1
gb_3 gb_3
end type
global ubs_w_reg_addin ubs_w_reg_addin

type variables
String 	is_serial_fr, 		is_contno_fr, &
			is_serial_to, 		is_contno_to,		is_file
Long		il_serial_len,	il_contno_len
DEC		il_serial_fr, 	il_serial_to, il_contno_fr, il_contno_to
end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine wf_change_no (string wfs_fr, string wfs_to, integer wfi_sw)
public function integer wf_maccheck (string as_macaddr)
public function integer wf_protect (string as_gubun)
end prototypes

public subroutine of_resizepanels ();dw_detail.Width = 1989
end subroutine

public subroutine wf_change_no (string wfs_fr, string wfs_to, integer wfi_sw);Long		ll_no
String 	ls_no_fr, 	ls_no_to, 	ls_val
Integer 	li_pos_fr, 	li_pos_to, &
			li_pos,		jj,  			li_asc, li_len

ls_no_fr 	= wfs_fr
ls_no_to 	= wfs_to

ll_no 	= 0

//===============>> FROM
li_pos 	= 0
li_len 	= LenA(ls_no_fr)

FOR jj =  li_len	 to 1 	step -1
	li_asc =  AscA(MidA(ls_no_fr, jj, 1))
	IF li_asc >= 48 AND li_asc <= 57 then
	ELSE
		li_pos = jj
		exit
	END IF
NEXT

IF li_pos > 0 AND li_pos < li_len then 
	li_pos_fr =  li_pos
ELSEIF li_pos = li_len THEN
	li_pos_fr = -1
ELSE
	li_pos_fr = 0
END IF

//==========================To
li_pos 	= 0
li_len 	= LenA(ls_no_to)

FOR jj =  li_len	 to 1 	step -1
	li_asc =  AscA(MidA(ls_no_to, jj, 1))
	IF li_asc >= 48 AND li_asc <= 57 then
	ELSE
		li_pos = jj
		exit
	END IF
NEXT

IF li_pos > 0 AND li_pos < li_len then 
	li_pos_to =  li_pos
ELSEIF li_pos = li_len THEN
	li_pos_to = -1
ELSE
	li_pos_to = 0
END IF

choose case wfi_sw
	case 1 // serial
		il_serial_len = li_len - li_pos_fr
		IF li_pos_fr <> -1 then
			is_serial_fr =  LeftA(ls_no_fr, li_pos_fr)
			il_serial_fr = DEC(MidA(ls_no_fr, li_pos_fr + 1, LenA(ls_no_fr) - li_pos_fr))
		END IF

		IF li_pos_to <> -1 then
			is_serial_to =  LeftA(ls_no_to, li_pos_to)
			il_serial_to = DEC(MidA(ls_no_to, li_pos_to + 1, LenA(ls_no_to) - li_pos_to))
		END IF
	case else //contno
		il_contno_len = li_len - li_pos_fr
		IF li_pos_fr <> -1 then
			is_contno_fr =  LeftA(ls_no_fr, li_pos_fr)
			il_contno_fr = Long(MidA(ls_no_fr, li_pos_fr + 1, LenA(ls_no_fr) - li_pos_fr))
		END IF

		IF li_pos_to <> -1 then
			is_contno_to =  LeftA(ls_no_to, li_pos_to)
			il_contno_to = Long(MidA(ls_no_to, li_pos_to + 1, LenA(ls_no_to) - li_pos_to))
		END IF
end choose

Return 
end subroutine

public function integer wf_maccheck (string as_macaddr);STRING	ls_temp
LONG		ll_length, ll_ascii
INT		ii

ll_length = LenA(as_macaddr)

IF ll_length <> 14 THEN
	Return -1	
END IF

FOR ii = 1 TO ll_length
	ls_temp = MidA(as_macaddr, ii, 1)
	
	ll_ascii = AscA(ls_temp)
	
	IF ll_ascii = 46 OR (ll_ascii >= 48 AND ll_ascii <= 57) OR (ll_ascii >= 97 AND ll_ascii <= 102) OR (ll_ascii >= 65 AND ll_ascii <= 70) THEN
		//숫자 0~9, 대문자 A~F
	ELSE
		RETURN -1
		EXIT
	END IF
NEXT

return 0
end function

public function integer wf_protect (string as_gubun);STRING	ls_modelno,		ls_equiptype
dw_master.AcceptText()

IF as_gubun = "C"	THEN				//CLEAR
	dw_detail.Object.serialno.Color = RGB(255, 255, 255)
	dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.serialno.Protect = 0	
	dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
	dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.dacom_mng_no.Protect = 0	
	dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.mac_addr.Protect = 0	
	dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
	dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr2.Protect = 0		
	dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
	dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.sap_no.Protect = 0
ELSEIF as_gubun = "1" THEN			//판매장비일 때
	ls_modelno = dw_master.Object.modelno[1]
	
	SELECT EQUIPTYPE INTO :ls_equiptype
	FROM   EQUIPMODEL
	WHERE  MODELNO = :ls_modelno;
	
//2009.08.14 이윤주 대리 요청. 판매장비는 무조건 시리얼과 맥1만 있으면 된다.	
//	IF ls_equiptype = "WF02" THEN
//		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
//		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.serialno.Protect = 1	
//		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
//		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.dacom_mng_no.Protect = 0			
//		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.mac_addr.Protect = 0			
//		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
//		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr2.Protect = 0		
//		dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.sap_no.Protect = 1				
//	ELSE
//		dw_detail.Object.serialno.Color = RGB(255, 255, 255)
//		dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)
//		dw_detail.Object.serialno.Protect = 0	
//		dw_detail.Object.dacom_mng_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.dacom_mng_no.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.dacom_mng_no.Protect = 1			
//		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.mac_addr.Protect = 0			
//		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
//		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr2.Protect = 0		
//		dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.sap_no.Protect = 1						
//	END IF
	
	dw_detail.Object.serialno.Color = RGB(255, 255, 255)
	dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)
	dw_detail.Object.serialno.Protect = 0	
	dw_detail.Object.dacom_mng_no.Color = RGB(0, 0, 0)
	dw_detail.Object.dacom_mng_no.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.dacom_mng_no.Protect = 1			
	dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.mac_addr.Protect = 0			
	dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
	dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr2.Protect = 0		
	dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
	dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
	dw_detail.Object.sap_no.Protect = 1						

ELSEIF as_gubun = "0" THEN					//임대장비
	
	ls_modelno = dw_master.Object.modelno[1]
	
	SELECT EQUIPTYPE INTO :ls_equiptype
	FROM   EQUIPMODEL
	WHERE  MODELNO = :ls_modelno;
	
	IF ls_equiptype = "VO01" THEN
		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
		dw_detail.Object.serialno.Protect = 0	
		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.dacom_mng_no.Protect = 0			
		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr.Protect = 0			
		dw_detail.Object.mac_addr2.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr2.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr2.Protect = 0		
		dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
		dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.sap_no.Protect = 0			
	ELSE
		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
		dw_detail.Object.serialno.Protect = 0	
		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.dacom_mng_no.Protect = 0			
		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr.Protect = 0			
		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr2.Protect = 0		
		dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
		dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.sap_no.Protect = 0
	END IF
END IF

return 0
end function

on ubs_w_reg_addin.create
int iCurrent
call super::create
this.dw_file=create dw_file
this.dw_temp=create dw_temp
this.gb_2=create gb_2
this.gb_1=create gb_1
this.gb_3=create gb_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
this.Control[iCurrent+2]=this.dw_temp
this.Control[iCurrent+3]=this.gb_2
this.Control[iCurrent+4]=this.gb_1
this.Control[iCurrent+5]=this.gb_3
end on

on ubs_w_reg_addin.destroy
call super::destroy
destroy(this.dw_file)
destroy(this.dw_temp)
destroy(this.gb_2)
destroy(this.gb_1)
destroy(this.gb_3)
end on

event ue_ok;long ll_cnt

//### 입고정보
String ls_modelno, ls_makercd, ls_entstore
String ls_idate
Long	 ll_iqty, ll_idamt, ll_inamt, ll_invat
String ls_ret_yn, ls_remark, ls_sale_flag

//add -- ssrt
String	ls_serial_fr, ls_serial_to	//Serial No
String	ls_contno_fr, ls_contno_to	//장비ControlNo
String 	ls_serial, 		ls_contno
Integer	li_pos,			li_len
Long		ll_serial_fr,		ll_serial_to, &
			ll_contno_fr,		ll_contno_to


If dw_master.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망
	dw_master.SetFocus()
	Return
End If

ls_modelno 	= Trim(dw_master.Object.modelno[1])
//ls_makercd	= Trim(dw_master.Object.makercd[1])
ls_idate 	= Trim(String(dw_master.Object.idate[1],'yyyymmdd'))
ls_entstore = Trim(dw_master.Object.entstore[1])
ll_iqty 		= dw_master.Object.iqty[1]
ll_idamt 	= dw_master.Object.idamt[1]
ll_inamt 	= dw_master.Object.inamt[1]
ll_invat 	= dw_master.Object.invat[1]
ls_ret_yn 	= Trim(dw_master.Object.ret_yn[1])
ls_remark 	= Trim(dw_master.Object.remark[1])
ls_sale_flag= Trim(dw_master.Object.sale_flag[1])

ls_serial_fr	= Trim(dw_master.Object.serial_fr[1])	// Serialno-from
ls_serial_to	= Trim(dw_master.Object.serial_to[1])	// Serialno-to
ls_contno_fr	= Trim(dw_master.Object.contno_fr[1])	// Contolno-from
ls_contno_to	= Trim(dw_master.Object.contno_to[1])	// Contolno-to

IF IsNull(ls_serial_fr) then ls_serial_fr = ''
IF IsNull(ls_serial_to) then ls_serial_to = ''
IF IsNull(ls_contno_fr) then ls_contno_fr = ''
IF IsNull(ls_contno_to) then ls_contno_to = ''

IF ls_serial_fr <> '' then			wf_change_no(ls_serial_fr, ls_serial_to, 1)
IF ls_contno_fr <> '' then			wf_change_no(ls_contno_fr, ls_contno_to, 2)

//### 필수데이터 체크

//제조사
//IF IsNull(ls_makercd) THEN
//	f_msg_usr_err(200, Title, "제조사")
//	dw_master.setColumn("makercd")
//	dw_master.setRow(1)
//	dw_master.setFocus()
//	RETURN
//END IF

//판매구분
IF IsNull(ls_sale_flag) THEN
	f_msg_usr_err(200, Title, "판매구분")
	dw_master.setColumn("sale_flag")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//모델명
IF IsNull(ls_modelno) THEN
	f_msg_usr_err(200, Title, "모델명")
	dw_master.setColumn("modelno")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//입고일자
IF IsNull(ls_idate) or ls_idate = "" THEN
	f_msg_usr_err(200, Title, "입고일자")
	dw_master.setColumn("idate")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//입고처
IF IsNull(ls_entstore) THEN
	f_msg_usr_err(200, Title, "입고처")
	dw_master.setColumn("entstore")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//입고단가
IF IsNull(ll_idamt) THEN
	f_msg_usr_err(200, Title, "입고단가")
	dw_master.setColumn("idamt")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//입고수량
IF IsNull(ll_iqty) THEN
	f_msg_usr_err(200, Title, "입고수량")
	dw_master.setColumn("iqty")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//공급가액
IF IsNull(ll_inamt) THEN
	f_msg_usr_err(200, Title, "공급가액")
	dw_master.setColumn("inamt")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//부가세
IF IsNull(ll_invat) THEN
	f_msg_usr_err(200, Title, "부가세")
	dw_master.setColumn("invat")
	dw_master.setRow(1)
	dw_master.setFocus()
	RETURN
END IF

//### 입고거래 기타정보 입력
//입고자
dw_master.Object.iman[1] = gs_user_id

//Log 정보
dw_master.Object.crt_user[1] 	= gs_user_id
dw_master.Object.crtdt[1] 		= fdt_get_dbserver_now()
dw_master.Object.updt_user[1] = gs_user_id
dw_master.Object.updtdt[1]		= fdt_get_dbserver_now()
dw_master.Object.pgm_id[1]		= gs_pgm_id[gi_open_win_no]

//### 장비마스터 정보 입력
Long ll_detailRow //dw_detail의 row수

ll_detailRow = dw_detail.rowCount()

Long ll_equipseq			//새 장비번호

wf_protect(ls_sale_flag)

//IF ls_sale_flag = '1' THEN			//판매장비이면  입력 못하게 막는다!
//	dw_detail.Object.dacom_mng_no.Color = RGB(0, 0, 0)
//	dw_detail.Object.dacom_mng_no.Background.Color = RGB(255, 255, 255)		
//	dw_detail.Object.dacom_mng_no.Protect = 1			
//	dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
//	dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)		
//	dw_detail.Object.sap_no.Protect = 1				
//END IF

//dw_detail의 row 수 > 입고정보에 입력된 입고수량
IF( ll_detailRow > ll_iqty ) THEN
	FOR ll_cnt = ll_iqty + 1 TO ll_detailRow
		dw_detail.deleteRow(ll_iqty + 1)	//수량차이 만큼 dw_detail에 Row삭제
	Next
ELSEIF( ll_detailRow < ll_iqty ) THEN
	FOR ll_cnt = ll_detailRow + 1 TO ll_iqty
		dw_detail.insertRow(ll_cnt)	//수량차이 만큼 dw_detail에 Row추가
		//장비번호
		//새 장비번호 추출
		SELECT seq_equipseq.nextval	INTO :ll_equipseq		FROM dual;

		dw_detail.Object.equipseq[ll_cnt] = ll_equipseq								//장비번호	
		dw_detail.Object.contno[ll_cnt]	 = STRING(ll_equipseq)					//contno
		dw_detail.Object.num[ll_cnt]		 = ll_cnt
		
		IF ls_serial_fr <> '' then
			dw_detail.Object.serialno[ll_cnt]	= is_serial_fr + RightA('0000000000' + String(il_serial_fr), il_serial_len)
			il_serial_fr ++
		ELSE
			dw_detail.Object.serialno[ll_cnt]	= ''
		END IF
//		IF ls_contno_fr <> '' then
//			dw_detail.Object.contno[ll_cnt]		= is_contno_fr + Right('0000000000' + String(il_contno_fr), il_contno_len)
//			il_contno_fr ++
//		ELSE
//			dw_detail.Object.contno[ll_cnt]		= ''
//		END IF
		
	Next
END IF

//File DW 활성화
dw_file.Enabled 	= True
dw_detail.Enabled = True

p_insert.TriggerEvent("ue_enable")
p_delete.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
LONG		ll_3,		ll_w_2,		ll_grsize,		ll_dwsize,		ll_wgrsize,		ll_w

ll_grsize  = 4    //그룹박스간 사이 간격!
ll_dwsize  = 50   //그룹박스와 dw사이 간격!
ll_wgrsize = 30	//좌우 그룹박스 간 간격!

If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
	gb_1.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	
	ll_3 					= newheight - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space
	dw_detail.Height	= newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - 25
	gb_2.Height			= dw_detail.Height + ll_dwsize
	
//	gb_2.Height			= gb_2.Height + ll_3
	
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
	gb_2.Width = 0
Else
	ll_w = newwidth - gb_3.x - gb_3.width - iu_cust_w_resize.ii_dw_button_space
	
	gb_2.Width			= gb_2.Width + ll_w
	dw_detail.Width   = gb_2.Width - ll_dwsize
	
	gb_3.x				= gb_2.x + gb_2.Width + ll_wgrsize
	dw_file.x		   = gb_3.x + 15	
End If

//If newwidth < dw_master.X  Then
//	dw_master.Width = 0
//Else
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
//End If

// Call the resize functions
of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

end event

event ue_reset;call super::ue_reset;p_ok.TriggerEvent("ue_enable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

dw_master.Enabled = True
dw_master.reset()
dw_master.insertRow(1)
dw_master.Object.idate[1]		= fdt_get_dbserver_now()
//dw_master.Object.sale_flag[1] = '1'
//dw_master.Object.modelno.Protect = TRUE

dw_temp.reset()
dw_file.reset()
dw_file.insertRow(1)
dw_file.Enabled = False

wf_protect("C")

//dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
//dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
//dw_detail.Object.dacom_mng_no.Protect = 0
//
//dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
//dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
//dw_detail.Object.sap_no.Protect = 0


RETURN 0

end event

event ue_extra_save;Long		ll_rows,			ll_rowcnt,			ll_equipseq,	ll_iseqno,		ll_idamt,		ll_seq, &
			ll_check,		ll_mac_cnt,			ll_mac_cnt2
STRING	ls_contno, 		ls_serialno,		ls_equiptype,	ls_modelno,		ls_itemcod,		&
			ls_status[], 	ls_adstat[],		ls_makercd,		ls_entstore,	ls_remark,		&
			ls_todt, 		ls_sale_flag,		ls_action,		ls_dacom_no,	ls_macaddr,		&
		   ls_macaddr2,	ls_valid_status[],ls_temp,													&
			ls_c1_color,	ls_c2_color,		ls_c3_color,	ls_c4_color, 	ls_c5_color, 	&
			ls_sap_no
DATETIME	ld_idate
DOUBLE	ldb_inamt, 		ldb_invat
DEC{2}	ldc_sale_amt
	
ls_makercd 		= Trim(dw_master.Object.makercd[1])							//제조사번호
ld_idate			= dw_master.Object.idate[1]									//입고일자
ll_idamt			= dw_master.Object.idamt[1]									//입고단가
ls_entstore 	= Trim(dw_master.Object.entstore[1])						//입고처
ls_remark		= Trim(dw_master.Object.remark[1])							//비고
ls_sale_flag	= Trim(dw_master.Object.sale_flag[1])						//판매구분
ls_modelno 		= Trim(dw_master.Object.modelno[1])							//모델번호
ls_todt			= String(fdt_get_dbserver_now(), 'yyyymmdd')				//현재일자
ldb_inamt      = dw_master.Object.inamt[1]									//공급가액
ldb_invat      = dw_master.Object.invat[1]									//부가세

IF ls_sale_flag = "" THEN
	f_msg_usr_err(200, Title, "판매구분")
	dw_master.setColumn("sale_flag")
	dw_detail.setRow(1)
	dw_detail.scrollToRow(1)
	dw_detail.setFocus()
	RETURN -2
END IF

//2011.03.02일 장비 아이템, 가격 찾아오기
SELECT ITEMCOD, SALE_AMT INTO :ls_itemcod, :ldc_sale_amt
FROM   EQUIPMODELMST
WHERE  MAKERCD = :ls_makercd
AND    MODELNO = :ls_modelno;

//2011.03.02일 주석처리. 위에쿼리로 대체
////Price read
//SELECT SALE_ITEM  INTO :ls_itemcod  FROM MODEL_PRICE
//WHERE  MODELNO =  :ls_modelno
//AND    TO_CHAR(fromdt, 'yyyymmdd') = ( SELECT MAX(TO_CHAR(FROMDT, 'yyyymmdd'))
//	                                    FROM   MODEL_PRICE
//													WHERE  MODELNO = :ls_modelno
//													AND    TO_CHAR(FROMDT, 'yyyymmdd') <= :ls_todt ) ;

IF IsNull(ls_itemcod) THEN ls_itemcod 	= ""

//장비입고상태,  입고/이동/임대/반납/판매등 - STATUS
SELECT ref_content INTO :ls_temp FROM sysctl1t 
WHERE  module = 'U0' AND ref_no = 'S100';
fi_cut_string(ls_temp, ";", ls_status[])

ls_temp = ""
//연구소 인증상태 첫번째 값(100) - VALID_STATUS
SELECT ref_content INTO :ls_temp FROM sysctl1t 
WHERE  module = 'U0' AND ref_no = 'S300';
fi_cut_string(ls_temp, ";", ls_valid_status[])

//장비상태 - ADSTAT (정상, 불량 등) 
ls_temp = ""
SELECT ref_content INTO :ls_temp FROM sysctl1t 
WHERE  module = 'U0' AND ref_no = 'S200';
fi_cut_string(ls_temp, ";", ls_adstat[])

//장비구분
SELECT EQUIPTYPE INTO :ls_equiptype FROM EQUIPMODEL
WHERE  MODELNO = :ls_modelno;

//로그 행위(action)추출
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A100';

//이동대리점
//SELECT ref_content INTO :ls_mv_partner FROM sysctl1t 
//WHERE module = 'A1' AND ref_no = 'C102';

//필수항목 Check
ll_rows	= dw_detail.RowCount()

//dw_master의 입고수량을 실제 입력된 row수로 정정한다.
dw_master.Object.iqty[1] = ll_rows

ls_c1_color = dw_detail.Object.serialno.Background.Color
ls_c2_color = dw_detail.Object.dacom_mng_no.Background.Color
ls_c3_color = dw_detail.Object.mac_addr.Background.Color
ls_c4_color = dw_detail.Object.mac_addr2.Background.Color
ls_c5_color = dw_detail.Object.sap_no.Background.Color

FOR ll_rowcnt = 1 TO ll_rows
	ls_serialno	= Trim(dw_detail.Object.serialno[ll_rowcnt])
	ls_contno	= Trim(dw_detail.Object.contno[ll_rowcnt])
	ls_dacom_no	= Trim(dw_detail.Object.dacom_mng_no[ll_rowcnt])
	ls_macaddr	= Trim(dw_detail.Object.mac_addr[ll_rowcnt])
	ls_macaddr2	= Trim(dw_detail.Object.mac_addr2[ll_rowcnt])
	ls_sap_no	= Trim(dw_detail.Object.sap_no[ll_rowcnt])	
	
	IF IsNull(ls_serialno) 	THEN ls_serialno 	= ""
	IF IsNull(ls_contno) 	THEN ls_contno 	= ""
	IF IsNull(ls_dacom_no) 	THEN ls_dacom_no 	= ""
	IF IsNull(ls_macaddr) 	THEN ls_macaddr 	= ""
	IF IsNull(ls_macaddr2) 	THEN ls_macaddr2 	= ""	
	IF IsNull(ls_sap_no) 	THEN ls_sap_no 	= ""		

	//Serial No. 체크
	IF ls_c1_color = "9212523" THEN
		IF ls_serialno = "" THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 Serial No.")
			dw_detail.setColumn("serialno")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2
		END IF
	END IF
	
	//dacom_mng_no No. 체크
	IF ls_c2_color = "9212523" THEN
		IF ls_dacom_no = "" THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 DACOM No.")
			dw_detail.setColumn("dacom_mng_no")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2
		END IF
	END IF
	
//	IF ls_sale_flag = '0' THEN		//데이콤 자산번호는 임대장비만 관리한다.
//		//데이콤 자산번호 체크
//		IF ls_dacom_no = "" THEN
//			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 DACOM No.")
//			dw_detail.setColumn("dacom_mng_no")
//			dw_detail.setRow(ll_rowcnt)
//			dw_detail.scrollToRow(ll_rowcnt)
//			dw_detail.setFocus()
//			RETURN -2
//		END IF	
//	END IF
	
	//mac_addr 체크
	IF ls_macaddr = "" THEN
		f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR")
		dw_detail.setColumn("mac_addr")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	ELSE
		ll_check = wf_maccheck(ls_macaddr)
		IF ll_check < 0 THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR")			
			dw_detail.setColumn("mac_addr")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2			
		END IF
		
		SELECT COUNT(*) INTO :ll_mac_cnt
		FROM   EQUIPMST
		WHERE  MAC_ADDR = LOWER(:ls_macaddr);
		
		SELECT COUNT(*) INTO :ll_mac_cnt2
		FROM   EQUIPMST
		WHERE  MAC_ADDR2 = LOWER(:ls_macaddr);	
		
		IF ll_mac_cnt > 0 OR ll_mac_cnt2 > 0 THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR 중복")						
			dw_detail.setColumn("mac_addr")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2
		END IF
		dw_detail.Object.mac_addr[ll_rowcnt] = LOWER(ls_macaddr)		
	END IF		
	
	//mac_addr2 체크
	IF ls_c4_color = "9212523" THEN
		IF ls_macaddr2 = "" THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR2")
			dw_detail.setColumn("mac_addr2")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2
		ELSE
			ll_check = wf_maccheck(ls_macaddr2)
			IF ll_check < 0 THEN
				f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR2")			
				dw_detail.setColumn("mac_addr2")
				dw_detail.setRow(ll_rowcnt)
				dw_detail.scrollToRow(ll_rowcnt)
				dw_detail.setFocus()
				RETURN -2			
			END IF
			
			SELECT COUNT(*) INTO :ll_mac_cnt
			FROM   EQUIPMST
			WHERE  MAC_ADDR = LOWER(:ls_macaddr2);
			
			SELECT COUNT(*) INTO :ll_mac_cnt2
			FROM   EQUIPMST
			WHERE  MAC_ADDR2 = LOWER(:ls_macaddr2);	
			
			IF ll_mac_cnt > 0 OR ll_mac_cnt2 > 0 THEN
				f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR2 중복")						
				dw_detail.setColumn("mac_addr2")
				dw_detail.setRow(ll_rowcnt)
				dw_detail.scrollToRow(ll_rowcnt)
				dw_detail.setFocus()
				RETURN -2
			END IF
			dw_detail.Object.mac_addr2[ll_rowcnt] = LOWER(ls_macaddr2)		
		END IF
	ELSE
		IF ls_macaddr2 <> "" THEN
			ll_check = wf_maccheck(ls_macaddr2)
			IF ll_check < 0 THEN
				f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR2")			
				dw_detail.setColumn("mac_addr2")
				dw_detail.setRow(ll_rowcnt)
				dw_detail.scrollToRow(ll_rowcnt)
				dw_detail.setFocus()
				RETURN -2			
			END IF
			
			ll_mac_cnt = 0
			ll_mac_cnt2 = 0
			
			SELECT COUNT(*) INTO :ll_mac_cnt
			FROM   EQUIPMST
			WHERE  MAC_ADDR = LOWER(:ls_macaddr);
			
			SELECT COUNT(*) INTO :ll_mac_cnt2
			FROM   EQUIPMST
			WHERE  MAC_ADDR2 = LOWER(:ls_macaddr);	
			
			IF ll_mac_cnt > 0 OR ll_mac_cnt2 > 0 THEN
				f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 MAC ADDR 중복")						
				dw_detail.setColumn("mac_addr")
				dw_detail.setRow(ll_rowcnt)
				dw_detail.scrollToRow(ll_rowcnt)
				dw_detail.setFocus()
				RETURN -2
			END IF		
			dw_detail.Object.mac_addr2[ll_rowcnt] = LOWER(ls_macaddr2)
		END IF		
	END IF
	
	//SAP_NO. 체크
	IF ls_c2_color = "9212523" THEN
		IF ls_sap_no = "" THEN
			f_msg_usr_err(200, Title, String(ll_rowcnt) + "번 SAP No.")
			dw_detail.setColumn("sap_no")
			dw_detail.setRow(ll_rowcnt)
			dw_detail.scrollToRow(ll_rowcnt)
			dw_detail.setFocus()
			RETURN -2
		END IF
	END IF		
	
	//Control No
	Int li_cnt
	
	SELECT COUNT(*) INTO :li_cnt FROM EQUIPMST
	WHERE  CONTNO = :ls_contno;
	
	IF li_cnt > 0 THEN
		f_msg_usr_err(201, Title, String(ll_rowcnt) + "번 Control No.[" + ls_contno + "]는 이미 저장된 번호입니다.")
		dw_detail.setColumn("contno")
		dw_detail.setRow(ll_rowcnt)
		dw_detail.scrollToRow(ll_rowcnt)
		dw_detail.setFocus()
		RETURN -2
	END IF	

	//장비번호
	ll_equipseq = dw_detail.Object.equipseq[ll_rowcnt]										//장비번호	
		
	//기타정보 입력
	dw_detail.Object.itemcod[ll_rowcnt]			= ls_itemcod							//Itemcod
	dw_detail.Object.adtype[ll_rowcnt]			= ls_equiptype							//장비구분
//	dw_detail.Object.dan_yn[ll_rowcnt]			= 'Y'										//단품여부
	dw_detail.Object.makercd[ll_rowcnt] 		= ls_makercd							//제조사번호
	dw_detail.Object.modelno[ll_rowcnt] 		= ls_modelno							//모델번호
	dw_detail.Object.status[ll_rowcnt]			= ls_status[3]							//장비입고상태,  신규/이동/예비/사용/반납등
	dw_detail.Object.valid_status[ll_rowcnt]	= ls_valid_status[1]					//연구소 인증상태
	dw_detail.Object.use_yn[ll_rowcnt]			= 'Y'										//사용가능여부
	dw_detail.Object.adstat[ll_rowcnt]			= ls_adstat[1]							//장비상태,  정상/파손/불량/분실/전환등
	dw_detail.Object.idate[ll_rowcnt]			= ld_idate								//입고일자
	dw_detail.Object.iseqno[ll_rowcnt]			= ll_iseqno								//입고번호
	dw_detail.Object.sn_partner[ll_rowcnt]		= gs_shopid								//입고 샵.  소유샵에서 작업하기에...
	dw_detail.Object.snmovedt[ll_rowcnt]		= ld_idate								//입고처로 보내야한다. 소유샵에서 작업하기에...	
	dw_detail.Object.idamt[ll_rowcnt]			= ll_idamt								//입고단가
	dw_detail.Object.sale_amt[ll_rowcnt]		= ldc_sale_amt							//판매가격
	dw_detail.Object.sale_flag[ll_rowcnt]		= ls_sale_flag							//판매임대구분
	dw_detail.Object.entstore[ll_rowcnt]		= ls_entstore							//입고처
	dw_detail.Object.remark[ll_rowcnt]			= ls_remark								//비고		
	dw_detail.Object.crt_user[ll_rowcnt]		= gs_user_id
	dw_detail.Object.crtdt[ll_rowcnt]			= fdt_get_dbserver_now()
	dw_detail.Object.pgm_id[ll_rowcnt]			= gs_pgm_id[gi_open_win_no]
	dw_detail.Object.new_yn[ll_rowcnt]			= 'Y'										//신규 구분
	dw_detail.Object.use_cnt[ll_rowcnt]			= 0										//사용횟수
		
//2009.06.07 장비이력 필요없음. 정T과 협의 후 주석처리.
	//장비이력(EQUIPLOG)에 Insert	
	INSERT INTO EQUIPLOG
	(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
	 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
	 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
	 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
	 SN_PARTNER,	SNMOVEDT,		IDAMT,	 	SALE_AMT,		ITEMCOD,
	 SALE_FLAG,		REMARK,			SAP_NO,	 	NEW_YN,			USE_CNT,
	 CRT_USER,		CRTDT,			PGM_ID )
	VALUES
	(:ll_equipseq,		SEQ_EQUIPLOG.NEXTVAL,	SYSDATE,							:ls_action,				:ls_serialno,
	 :ls_contno,		:ls_dacom_no,				:ls_macaddr,					:ls_macaddr2,			:ls_equiptype,
	 :ls_makercd,		:ls_modelno,				:ls_status[3],					:ls_valid_status[1],	'Y',
	 :ls_adstat[1], 	:ld_idate,					:ll_iseqno,						:ls_entstore,			null,
	 :gs_shopid,		:ld_idate,					:ll_idamt,						:ldc_sale_amt,			:ls_itemcod,
	 :ls_sale_flag, 	:ls_remark,					:ls_sap_no,						'Y',						0,
	 :gs_user_id, 		SYSDATE,						:gs_pgm_id[gi_open_win_no]);
	 
	IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "EQUIPLOG INSERT Error")
		return -1
	END IF		 
NEXT

//No Error
RETURN 0
end event

event type integer ue_save();Constant Int LI_ERROR = -1

Long result

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
End if

//새 입고번호
Long ll_iseqno

SELECT SEQ_EQUIPINSEQ.NEXTVAL INTO :ll_iseqno FROM DUAL;

//새 입고번호 dw_master에 입력
dw_master.Object.iseqno[1] = ll_iseqno

//새 입고번호 dw_detail에 입력
Long ll_cnt
FOR ll_cnt = 1 TO dw_detail.rowCount()
	dw_detail.Object.iseqno[ll_cnt] = ll_iseqno
NEXT

If (dw_master.Update() < 0) or (dw_detail.Update() < 0) then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else

//2009.06.07 정T 과 협의 후 주석처리.	
//	//모델(admodel) Table에 입고장비 수 만큼 재고수량(stockqty) 추가
//	Long 		ll_iqty
//	String	ls_modelno
//	
//	ll_iqty 		= dw_detail.rowCount()
//	ls_modelno 	= Trim(dw_master.Object.modelno[1])
//	
//	UPDATE admodel
//	SET    stockqty = stockqty + :ll_iqty
//	WHERE  modelno = :ls_modelno;
//2009.06.07-----------------------------END
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End if

//저장완료
//TriggerEvent("ue_reset")
p_ok.TriggerEvent("ue_disable")

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")

dw_master.Enabled = False
dw_file.Enabled = False
dw_detail.Enabled = False
This.TriggerEvent("ue_reset")

//ii_error_chk = 0
Return 0

end event

event open;call super::open;dw_master.Object.idate[1]		= fdt_get_dbserver_now()
//dw_master.Object.sale_flag[1] = '1'

dw_file.Enabled = False

end event

event type integer ue_insert();Constant Int LI_ERROR = -1
Long ll_row

ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)

//장비번호
//새 장비번호 추출
Long ll_equipseq			//새 장비번호

	SELECT SEQ_EQUIPSEQ.nextval
	INTO :ll_equipseq
	FROM dual;

dw_detail.Object.equipseq[ll_row]	= ll_equipseq							//장비번호	
dw_detail.Object.contno[ll_row]		= STRING(ll_equipseq)				//CONTNO
		
dw_detail.Object.num[ll_row] = ll_row

dw_detail.ScrollToRow(ll_row)
dw_detail.SetRow(ll_row)
dw_detail.SetFocus()

dw_master.Object.iqty[1] = ll_row

Return 0

end event

event type integer ue_delete();Long ll_row
Long ll_cnt

ll_row = dw_detail.getRow()

IF(ll_row > 1 ) THEN

	dw_detail.DeleteRow(ll_row)
	
	FOR ll_cnt=ll_row to dw_detail.rowCount()
		dw_detail.Object.num[ll_cnt] = dw_detail.Object.num[ll_cnt] -1
	Next
	
	dw_master.Object.iqty[1] = dw_detail.rowCount()

END IF

Return 0

end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_addin
boolean visible = false
integer x = 3104
integer y = 536
integer width = 101
integer height = 48
end type

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_addin
integer x = 2990
integer y = 44
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_addin
integer x = 1225
integer y = 1652
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_addin
boolean visible = false
integer x = 3067
integer y = 488
integer width = 174
integer height = 120
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_addin
event ue_cal ( )
integer y = 32
integer width = 2912
integer height = 648
string dataobject = "ubs_dw_reg_addin_mas"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_master::ue_cal();//공급가액과 부가세를 계산해주는 Event
this.AcceptText()

IF (not IsNull(THIS.Object.iqty[1])) AND (not IsNull(THIS.Object.idamt[1])) THEN
			THIS.Object.inamt[1]	= THIS.Object.iqty[1] * THIS.Object.idamt[1]	//공급가액
			THIS.Object.invat[1]	= Round(THIS.Object.inamt[1] *0.1,0)			//부가세
END IF
end event

event dw_master::itemchanged;call super::itemchanged;This.AcceptText()

CHOOSE CASE UPPER(dwo.Name)
	CASE "IDAMT"
		TriggerEvent("ue_cal")

	CASE "IQTY"
		TriggerEvent("ue_cal")
		
	CASE "SALE_FLAG"
		THIS.Object.modelno[row] = ""
		
		DataWindowChild ldc
		String ls_filter
		Long ll_row
		ll_row = This.GetChild("modelno", ldc)
		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
		ls_filter = "sale_flag = '" + data + "' "
		ldc.SetFilter(ls_filter)			//Filter정함
		ldc.Filter()
		ldc.SetTransObject(SQLCA)
		ll_row =ldc.Retrieve() 
	
		If ll_row < 0 Then 				//디비 오류 
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return -2
		End If
		
//2009.06.07 제조사와 모델관의 연결관계 제거! 정T 과 협의		
//	CASE "MAKERCD"
//		//제조사에 해당하는 모델만 보여주기..
//		DataWindowChild ldc
//		String ls_filter
//		Long ll_row
//		ll_row = This.GetChild("modelno", ldc)
//		If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
//		ls_filter = "makercd = '" + This.Object.makercd[1] + "' "
//		ldc.SetFilter(ls_filter)			//Filter정함
//		ldc.Filter()
//		ldc.SetTransObject(SQLCA)
//		ll_row =ldc.Retrieve() 
//	
//		If ll_row < 0 Then 				//디비 오류 
//			f_msg_usr_err(2100, Title, "Retrieve()")
//			Return -2
//		End If
//		
//		This.Object.modelno.Protect = False
//	
//	CASE "MODELNO"
//		//제조사에 해당하는 모델만 보여주기..
//		IF( IsNull(This.Object.makercd[1]) OR This.Object.makercd[1] = "") THEN
//			f_msg_usr_err(200, Title, "제조사")
//			//This.Object.modelno[1] = ""
//			
//			This.setColumn("makercd")
//			This.setRow(1)
//			This.setFocus()	
//		END IF
//2009.06.07---------------------------------------------END		
	case 'SERIAL_FR'
		This.Object.serial_to[1] =  data
	case 'CONTNO_FR'
		This.Object.contno_to[1] =  data
END CHOOSE

end event

event dw_master::clicked;//상속막음
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_addin
integer x = 41
integer y = 752
integer width = 1952
integer height = 848
string dataobject = "ubs_dw_reg_addin_det"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::itemchanged;call super::itemchanged;long	ll_foundrow,		ll_cnt
String ls_msg

CHOOSE CASE dwo.name
	CASE 'contno'
		SELECT Count(*)	  INTO :ll_cnt		  FROM EQUIPMST
		 WHERE CONTNO 			= :DATA  ;
		
		IF IsNull(ll_cnt) OR sqlca.sqlcode < 0 then ll_cnt = 0
		
		IF ll_cnt > 0 THEN
			ls_msg  = "Control No가 이미 존재합니다. 확인 후 다시 입력해 주시기 바랍니다."
			f_msg_info(9000, PARENT.Title, ls_msg)
			this.Object.contno[row] 	= ""
			return 1
		END IF
		
		ll_cnt 			= this.RowCount()
		IF row > 1 then
			//1 Before
			ll_foundrow = this.Find("contno = '" + data + "'", 1, row - 1)
			if ll_foundrow > 0 THEN
				ls_msg  = "이미 입력됨. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			END IF
			//2. After
			IF ll_cnt > row then
				ll_foundrow = this.Find("contno = '" + data + "'", row + 1, ll_cnt)
				if ll_foundrow > 0 THEN
					ls_msg  = "이미 입력됨. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
					f_msg_info(9000, PARENT.Title, ls_msg)
					this.Object.contno[row] = ""
					return 1
				END IF
			END IF
		ELSEIF row = 1 and ll_cnt > 1 then
			ll_foundrow = this.Find("contno = '" + data + "'", 2, ll_cnt)
			if ll_foundrow > 0 THEN
				ls_msg  = "이미 입력됨. ~t~n Control No. 확인 후 다시 입력해 주시기 바랍니다."
				f_msg_info(9000, PARENT.Title, ls_msg)
				this.Object.contno[row] = ""
				return 1
			END IF
		END IF
	CASE ELSE
END CHOOSE
					
					

end event

event dw_detail::itemerror;call super::itemerror;RETURN 1
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_addin
integer y = 1652
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_addin
integer x = 329
integer y = 1652
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_addin
integer x = 626
integer y = 1652
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_addin
integer x = 928
integer y = 1652
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_addin
integer y = 700
end type

type dw_file from datawindow within ubs_w_reg_addin
integer x = 2048
integer y = 748
integer width = 1239
integer height = 252
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_addin_file"
boolean border = false
boolean livescroll = true
end type

event buttonclicked;String 	ls_fileName, 		ls_sale_flag, 		ls_modelno, 		ls_equiptype,		&
			ls_fileRow1, 		ls_fileRow2, 		ls_fileRow3,		ls_fileRow4,		&
			ls_fileRow5,		ls_fileRow6,		ls_fileRow,			ls_serial,			&
			ls_dacom_no,		ls_mac_addr,		ls_mac_addr2,		ls_sap_no,			&
			pathname,			filename,			ls_save_file
Long		ll_fileRows = 0,	ll_iqty,				ll_equipseq,		ll_row,				&
			ll_return,			ll_iqty_temp,		ll_xls
Int		li_location1, 		li_location2,		li_location3,		li_location4,		&
			li_location5,		li_location6,		ii,					li_fileId,			&
			value,				li_cnt,				li_rtn

CHOOSE CASE	dwo.Name
	CASE "search"	//파일찾기
	
		value = GetFileOpenName("Select File", &
					+ pathName, fileName, "TXT", &
					+ "Text Files (*.TXT),*.TXT")

		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
	
	CASE "search_xls"			//엑셀 파일 찾기
		value = GetFileOpenName("Select File", pathName, fileName, "All Files (*.*),*.*", 'Excel Files (*.xls), *.xls')		
		
		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
		OleObject oleExcel 
		
		oleExcel = Create OleObject 
		li_rtn = oleExcel.connecttonewobject("excel.application") 
		
		IF value = 1 THEN
			IF li_rtn = 0 THEN
				oleExcel.WorkBooks.Open(pathName) 
			ELSE
				Messagebox("!", "실패") 
				Destroy oleExcel 
				Return -1
			END IF
		ELSE
			Destroy oleExcel 
			Return -1
		END IF
		
		oleExcel.Application.Visible = False 
		
		ll_xls = PosA(pathName, 'xls')
		ls_save_file = MidA(pathName, 1, ll_xls -2) + '.txt'
		is_file = ls_save_file

		oleExcel.application.workbooks(1).SaveAs(ls_save_file, -4158) 
		oleExcel.application.workbooks(1).Saved = True 
		oleExcel.Application.Quit 
		oleExcel.DisConnectObject() 
		Destroy oleExcel
		
	CASE "load"		//파일처리
		
		ls_fileName  = Trim(This.Object.filename[1])
		ls_sale_flag = Trim(dw_master.Object.sale_flag[1])
		ls_modelno	 = Trim(dw_master.Object.modelno[1])
		
		IF isNull(ls_fileName) THEN ls_fileName = ""
				
		IF ls_fileName = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		SELECT EQUIPTYPE INTO :ls_equiptype
		FROM   EQUIPMODEL
		WHERE  MODELNO = :ls_modelno;
		
		li_fileId = FileOpen(ls_fileName, LineMode!) //한줄씩 읽어오기
		
		If(IsNull(li_fileId) or li_fileId < 0) THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If

		ll_iqty = dw_detail.rowCount()
		
		//End of File(return -100)을 만날때까지 파일을 한줄씩 읽는다.
		DO UNTIL( FileRead(li_fileId,ls_fileRow) = -100 )
			
			IF(ls_fileRow <> "") THEN
			
				ll_fileRows++
				
				IF( ll_iqty < ll_fileRows) THEN //입고예정 수량보다 파일row수가 많은 경우
					ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)
	
					//장비번호
					//새 장비번호 추출
					SELECT seq_equipseq.nextval INTO :ll_equipseq 	FROM dual;
					
					dw_detail.Object.equipseq[ll_row]	= ll_equipseq								//장비번호	
					dw_detail.Object.contno[ll_row]		= STRING(ll_equipseq)					//CONTNO
							
					dw_detail.Object.num[ll_row] = ll_row
					
					dw_master.Object.iqty[1] = ll_row
				END IF
				
//				//ls_fileRow에 저장된 시리얼넘버를 얻어온다.
				li_location1 = PosA(ls_fileRow,",")						 //첫번째 ","    serialno
				li_location2 = PosA(ls_fileRow,",",li_location1 + 1) //두번째 ","    dacom_mng_no
				li_location3 = PosA(ls_fileRow,",",li_location2 + 1) //세번째 ","	  mac_addr
				li_location4 = PosA(ls_fileRow,",",li_location3 + 1) //네번째 ","	  mac_addr2				
				li_location5 = li_location4 + 1							 //다섯번째 ","  sap_no
		
				//추출된 시리얼넘버
				ls_fileRow1 = TRIM(LeftA(ls_fileRow, li_location1 - 1))
				IF li_location2 > 1 then	
					ls_fileRow2 = TRIM(MidA(ls_fileRow,  li_location1 + 1, (li_location2 - li_location1 - 1 )))
				ELSE
					ls_fileRow2 = ''
				END IF
				IF li_location3 > 1 then	
					ls_fileRow3 = TRIM(MidA(ls_fileRow,  li_location2 + 1, (li_location3 - li_location2 - 1 )))
				ELSE
					ls_fileRow3 = ''
				END IF				
				IF li_location4 > 1 then	
					ls_fileRow4 = TRIM(MidA(ls_fileRow,  li_location3 + 1, (li_location4 - li_location3 - 1 )))
				ELSE
					ls_fileRow4 = ''
				END IF	
				IF li_location5 > 1 then	
					ls_fileRow5 = TRIM(MidA(ls_fileRow,  li_location4 + 1))
				ELSE
					ls_fileRow5 = ''
				END IF								
				
				IF(ls_fileRow <> "") THEN
					IF ls_sale_flag = "1" THEN			//판매장비
					   //2009.08.14 이윤주 대리 요청사항. 판매장비는 시리얼, 맥1, 맥2만..
//						IF ls_equiptype = "WF02" THEN							
//							dw_detail.Object.dacom_mng_no[ll_fileRows] 	= ls_fileRow2
//							dw_detail.Object.mac_addr[ll_fileRows] 		= ls_fileRow3
//							dw_detail.Object.mac_addr2[ll_fileRows] 		= ls_fileRow4
//						ELSE
//							dw_detail.Object.serialno[ll_fileRows] 		= ls_fileRow1
//							dw_detail.Object.mac_addr[ll_fileRows] 		= ls_fileRow3
//							dw_detail.Object.mac_addr2[ll_fileRows] 		= ls_fileRow4							
//						END IF
						dw_detail.Object.serialno[ll_fileRows] 		= ls_fileRow1
						dw_detail.Object.mac_addr[ll_fileRows] 		= ls_fileRow3
						dw_detail.Object.mac_addr2[ll_fileRows] 		= ls_fileRow4							
					ELSE
						IF ls_equiptype = "VO01" THEN
							dw_detail.Object.serialno[ll_fileRows] 		= ls_fileRow1
							dw_detail.Object.dacom_mng_no[ll_fileRows] 	= ls_fileRow2
							dw_detail.Object.mac_addr[ll_fileRows] 		= ls_fileRow3
							dw_detail.Object.mac_addr2[ll_fileRows] 		= ls_fileRow4
							dw_detail.Object.sap_no[ll_fileRows]		 	= ls_fileRow5
						ELSE
							dw_detail.Object.serialno[ll_fileRows] 		= ls_fileRow1
							dw_detail.Object.dacom_mng_no[ll_fileRows] 	= ls_fileRow2
							dw_detail.Object.mac_addr[ll_fileRows] 		= ls_fileRow3
							dw_detail.Object.mac_addr2[ll_fileRows] 		= ls_fileRow4
							dw_detail.Object.sap_no[ll_fileRows]		 	= ls_fileRow5
						END IF
					END IF
				END IF
			END IF	
		LOOP
		
		FileClose(li_fileId) //파일닫기
		
		//입력예정인 수량보다 파일에서 읽은 시리얼넘버가 작을 경우 경고
		IF(dw_detail.rowcount() > ll_fileRows) THEN
			MessageBox("Serial No.부족","입고수량보다 파일로 입력된 Serial No.수량이 적습니다.")
			ll_fileRows++
		END IF
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_fileRows)
		dw_detail.SetRow(ll_fileRows)
		dw_detail.SetFocus()
		
	CASE "xls_load"		//파일처리
		
//		ls_fileName  = Trim(This.Object.filename[1])
		ls_sale_flag = Trim(dw_master.Object.sale_flag[1])
		ls_modelno	 = Trim(dw_master.Object.modelno[1])
		
		IF isNull(is_file) THEN is_file = ""
				
		IF is_file = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		SELECT EQUIPTYPE INTO :ls_equiptype
		FROM   EQUIPMODEL
		WHERE  MODELNO = :ls_modelno;
		
		ll_return = dw_temp.ImportFile(is_file)
		
		If ll_return < 0 THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If		

		ll_iqty 		 = dw_detail.rowCount()
		ll_iqty_temp = dw_temp.rowCount()	
		
		FOR ii = 1 TO ll_iqty_temp
			IF ii > ll_iqty THEN						//입고예정 수량보다 파일 ROW수가 많은 경우
				ll_row = dw_detail.InsertRow(dw_detail.Rowcount() + 1)
				
				//새 장비번호 추출
				SELECT seq_equipseq.nextval INTO :ll_equipseq 	FROM dual;
					
				dw_detail.Object.equipseq[ll_row]	= ll_equipseq								//장비번호	
				dw_detail.Object.contno[ll_row]		= STRING(ll_equipseq)					//CONTNO
				dw_detail.Object.num[ll_row] = ll_row
				dw_master.Object.iqty[1] = ll_row
			END IF
			
			ls_serial		= dw_temp.Object.serialno[ii]
			ls_dacom_no		= dw_temp.Object.dacom_mng_no[ii]
			ls_mac_addr		= dw_temp.Object.mac_addr[ii]
			ls_mac_addr2	= dw_temp.Object.mac_addr2[ii]
			ls_sap_no		= dw_temp.Object.sap_no[ii]

			IF ls_sale_flag = "1" THEN			//판매장비
			   //2009.08.14 이윤주 대리 요청사항. 판매장비는 시리얼, 맥1, 맥2만..			
//				IF ls_equiptype = "WF02" THEN
//					dw_detail.Object.dacom_mng_no[ii] 	= ls_dacom_no
//					dw_detail.Object.mac_addr[ii] 		= ls_mac_addr
//					dw_detail.Object.mac_addr2[ii] 		= ls_mac_addr2
//				ELSE
//					dw_detail.Object.serialno[ii] 		= ls_serial
//					dw_detail.Object.mac_addr[ii] 		= ls_mac_addr
//					dw_detail.Object.mac_addr2[ii] 		= ls_mac_addr2							
//				END IF
				dw_detail.Object.serialno[ii] 		= ls_serial
				dw_detail.Object.mac_addr[ii] 		= ls_mac_addr
				dw_detail.Object.mac_addr2[ii] 		= ls_mac_addr2							
				
			ELSE
				IF ls_equiptype = "VO01" THEN
					dw_detail.Object.serialno[ii] 		= ls_serial
					dw_detail.Object.dacom_mng_no[ii] 	= ls_dacom_no
					dw_detail.Object.mac_addr[ii] 		= ls_mac_addr
					dw_detail.Object.mac_addr2[ii] 		= ls_mac_addr2
					dw_detail.Object.sap_no[ii]		 	= ls_sap_no
				ELSE
					dw_detail.Object.serialno[ii] 		= ls_serial
					dw_detail.Object.dacom_mng_no[ii] 	= ls_dacom_no
					dw_detail.Object.mac_addr[ii] 		= ls_mac_addr
					dw_detail.Object.mac_addr2[ii] 		= ls_mac_addr2
					dw_detail.Object.sap_no[ii]		 	= ls_sap_no
				END IF
			END IF
		NEXT
		
		//입력예정인 수량보다 파일에서 읽은 시리얼넘버가 작을 경우 경고
		IF(dw_detail.rowcount() > ll_iqty_temp) THEN
			MessageBox("입고수량 부족", "파일로 입력된 입고수량이 부족합니다.")
			ll_iqty_temp++
		END IF
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_iqty_temp)
		dw_detail.SetRow(ll_iqty_temp)
		dw_detail.SetFocus()		
						
END CHOOSE
end event

event constructor;InsertRow(0)
end event

type dw_temp from datawindow within ubs_w_reg_addin
boolean visible = false
integer x = 2382
integer y = 1052
integer width = 832
integer height = 432
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_addin_temp"
boolean livescroll = true
end type

event constructor;	SetTransObject(SQLCA)
end event

type gb_2 from groupbox within ubs_w_reg_addin
integer x = 18
integer y = 728
integer width = 1998
integer height = 888
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

type gb_1 from groupbox within ubs_w_reg_addin
integer x = 18
integer y = 8
integer width = 3287
integer height = 692
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

type gb_3 from groupbox within ubs_w_reg_addin
integer x = 2039
integer y = 732
integer width = 1262
integer height = 276
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

